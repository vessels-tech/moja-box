PROJECT = "MOJA-BOX"
dir = $(shell pwd)

red:=$(shell tput setaf 1)
grn:=$(shell tput setaf 2)
ylw:=$(shell tput setaf 3)
blu:=$(shell tput setaf 4)
cyn:=$(shell tput setaf 5)
reset:=$(shell tput sgr0)

include .stage_config
include ./config/.compiled_env
env_dir := $(dir)/config

install:
	$(info $(cyn)[Installing moja-box dependencies]$(reset))
	brew install terraform kubernetes-cli kubernetes-helm
	brew tap caskroom/cask
	brew cask install google-cloud-sdk
	echo "TODO: check for ./config/default.json"
	gcloud components update
	gcloud auth application-default login

	touch install

build:
	$(info $(cyn)[Building Environment]$(reset))
	gcloud config set compute/zone asia-southeast1-a
	gcloud config set project moja-box
	cp ./terraform/secrets.auto.tfvars.example ./terraform/secrets.auto.tfvars

	# TODO: set up private envs
	cat ./config/gcp.private.sh || cp ./config/mojaloop.private.example.sh ./config/gcp.private.sh
	cat ./config/local.private.sh || cp ./config/mojaloop.private.example.sh ./config/local.private.sh
	
	# TODO: Add install etc stuff
	cd ./terraform && terraform init
	touch build

##
# Environment config
##
env:
	@cat ${env_dir}/${stage}.public.sh ${env_dir}/${stage}.private.sh > ${env_dir}/.compiled_env

switch:
	@echo switching to stage: ${stage}
	@echo 'export stage=${stage}\n' > .stage_config
	@make env

switch-local:
	make switch stage="local"
	#This might not work here, but we can make sure that make doesn't complete steps
	@touch deploy-kube deploy-dns config-set-lb-ip helm-fix-permissions

switch-gcp:
	make switch stage="gcp"


##
# Deployment
##
deploy-kube:
	$(info $(cyn)[deploy-kube]$(reset))
	@cd ./terraform && terraform apply -target=module.cluster -target=module.network

	#get the currently running clusters
	gcloud container clusters list
	gcloud container clusters get-credentials moja-box-cluster

	@touch deploy-kube

deploy-dns:
	$(info $(cyn)[deploy-dns]$(reset))
	@cd ./terraform && terraform apply -target=module.dns

	@touch deploy-dns

deploy-infra-destroy:
	@cd ./terraform && terraform destroy

deploy-helm:
	$(info $(cyn)[deploy-helm]$(reset))
	helm init

	@touch deploy-helm

deploy-moja:
	$(info $(cyn)[deploy-moja]$(reset))

	$(info $(grn)- Installing Mojaloop$(reset))
	helm repo add mojaloop http://mojaloop.io/helm/repo/
	helm install -f ./ingress.values.yml --debug --namespace=mojaloop --name=dev --repo=http://mojaloop.io/helm/repo mojaloop
	helm repo update

	$(info $(grn)- Installing Nginx$(reset))
	helm --namespace=mojaloop install stable/nginx-ingress --name=nginx

	@make print-hosts-settings

	$(info $(grn)- Installing Kubernetes dasboard$(reset))
	helm install stable/kubernetes-dashboard \
		--namespace kube-dash \
		--name kube-dash \
  	--set rbac.clusterAdminRole=true,enableSkipLogin=true,enableInsecureLogin=true
	
	@touch deploy-moja

deploy:
	$(info $(cyn)[deploy]$(reset))
	build
	deploy-kube
	deploy-helm
	#@ Fix issues with helm permissions on GCP Kube
	helm-fix-permissions
	deploy-moja
	#@ Load balancer will be live now, we can set up the lb env var
	config-set-lb-ip
	deploy-dns


##
# Destroyment
##

destroy-kube:
	$(info $(red)[destroy-kube]$(reset))
	@cd ./terraform && terraform destroy -target=module.cluster -target=module.network

	rm -f deploy-helm deploy-moja deploy-kube config-set-lb-ip helm-fix-permissions

destroy-dns:
	$(info $(red)[destroy-dns]$(reset))
	@cd ./terraform && terraform destroy -target=module.dns

	@rm -f deploy-dns

destroy-moja:
	$(info $(red)[destroy-moja]$(reset))
	helm del --purge kube-dash || echo 'Already deleted'
	helm del --purge nginx || echo 'Already deleted'
	helm del --purge dev || echo 'Already deleted'

	@rm -f deploy-moja


##
# Configuration
##
config-all:
	@make config-set-up config-create-dfsps

config-set-up:
	$(info $(cyn)[config-set-up]$(reset))
	@make env
	@./mojaloop_config/00_set_up_env.sh
	@touch config-set-up
	@echo 'Done!'

config-create-dfsps:
	$(info $(cyn)[config-create-dfsps]$(reset))
	@make env
	@./mojaloop_config/01_create_dfsps.sh
	@touch config-create-dfsps
	@echo 'Done!'

# set the correct load balancer ip
# we rely on a separate script as variable subs
# in make are hard
config-set-lb-ip:
	$(info $(cyn)[config-set-lb-ip]$(reset))
	@./config/_set_up_lb_ip.sh
	@make env
	@touch config-set-lb-ip

config-update-ingress:
	$(info $(cyn)[config-update-ingress]$(reset))
	helm upgrade -f ./ingress.values.yml --repo http://mojaloop.io/helm/repo dev mojaloop


##
# Examples
##
example-create-transfer:
	@./mojaloop_config/02_create_transfer.sh


##
# Misc
## 
helm-fix-permissions:
	$(info $(cyn)[helm-fix-permissions]$(reset))
	$(info $(grn)- Give helm the necessary permissions to install things on the cluster$(reset))
	kubectl -n kube-system delete serviceAccounts tiller || echo 'nothing to delete'
	kubectl -n kube-system delete clusterrolebindings tiller-cluster-rule || echo 'nothing to delete'
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

	$(info $(grn)- patch the permissions$(reset))
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	helm init --service-account tiller --upgrade
	sleep 15

	$(info $(grn)- running 'helm list' to test fix$(reset))
	helm list

	@touch helm-fix-permissions

print-hosts-settings:
	@echo "Make sure your /etc/hosts contains the following:\n"
	@echo '  ${CLUSTER_IP}	interop-switch.local central-kms.local forensic-logging-sidecar.local central-ledger.local central-end-user-registry.local central-directory.local central-hub.local central-settlement.local ml-api-adapter.local'

proxy-kube-dash:
	$(info $(cyn)[proxy-kube-dash]$(reset))
	@echo "Go to: http://localhost:8002/api/v1/namespaces/kube-dash/services/kube-dash-kubernetes-dashboard:http/proxy/"
	@kubectl proxy --port 8002

health-check:
	$(info $(cyn)[health-check]$(reset))
	@make env
	$(info $(grn)- Checking ingress health$(reset))
	curl -H Host:'central-ledger.local' http://${CLUSTER_IP}/health
	@echo ''
	$(info $(grn)- Checking dns health$(reset))
	curl -H Host:'central-ledger.local' http://moja-box.vessels.tech/health

print-ip:
	echo 'Warning! This is the cluster endpoint, and not the loadbalancer endpoint!'
	@cd ./terraform && terraform output |  grep loadbalancer | awk 'BEGIN { FS = " = " }; { print $$2 }'

print-endpoints:
	@kubectl get ep -n mojaloop

print-lb-ip:
	@gcloud compute forwarding-rules list | tail -1 | cut -f5 -d " "

remove-helm:
	helm reset --force

clean:
	rm -f config-* deploy-* helm-* build


.PHONY: switch env 