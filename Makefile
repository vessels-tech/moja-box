PROJECT = "MOJA-BOX"
dir = $(shell pwd)
include ./config/.compiled_env
env_dir := $(dir)/config


##
# Env
##

env:
	cat ${env_dir}/mojaloop.public.sh ${env_dir}/mojaloop.private.sh > ${env_dir}/.compiled_env


##
# Deployment
##
deploy-infra:
	@cd terraform && terraform plan

deploy-infra-apply:
	@cd ./terraform && terraform apply

deploy-infra-destroy:
	@cd ./terraform && terraform destroy

deploy-kube:	
	#get the currently running clusters
	gcloud container clusters list
	gcloud container clusters get-credentials moja-box-cluster

	#init helm
	helm init

	#Fix up permissions for helm to work
	make helm-fix-permissions
	kubectl -n kube-system get pod | grep tiller

	@echo 'Installing Mojaloop'
	helm repo add mojaloop http://mojaloop.io/helm/repo/
	helm install --debug --namespace=mojaloop --name=dev --repo=http://mojaloop.io/helm/repo mojaloop
	helm repo update

	@echo installing Nginx
	helm --namespace=mojaloop install stable/nginx-ingress --name=nginx

	@make print-hosts-settings

	@echo installing Kubernetes dasboard
	helm install stable/kubernetes-dashboard \
		--namespace kube-dash \
		--name kube-dash \
  	--set rbac.clusterAdminRole=true,enableSkipLogin=true,enableInsecureLogin=true



deploy:
	make deploy-infra-apply
	make deploy-kube

##
# Configuration
##
config-all:
	@make config-set-up config-create-dfsps

config-set-up:
	@make env
	@./mojaloop_config/00_set_up_env.sh
	@echo 'Done!'

config-create-dfsps:
	@make env
	@./mojaloop_config/01_create_dfsps.sh
	@echo 'Done!'



##
# Misc
## 
helm-fix-permissions:
	@helm list || echo 'command failed'

	#Give helm the necessary permissions to install stuff on the cluster
	kubectl -n kube-system delete serviceAccounts tiller || echo 'nothing to delete'
	kubectl -n kube-system delete clusterrolebindings tiller-cluster-rule || echo 'nothing to delete'
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

	#patch the permissions
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
	helm init --service-account tiller --upgrade
	sleep 5

	helm list || echo 'helm list failed. May not be fatal'


print-hosts-settings:
	@echo "Make sure your /etc/hosts contains the following:\n"
	@echo '  ${CLUSTER_IP}	interop-switch.local central-kms.local forensic-logging-sidecar.local central-ledger.local central-end-user-registry.local central-directory.local central-hub.local central-settlement.local ml-api-adapter.local'

proxy-kube-dash:
	@echo "Go to: http://localhost:8002/api/v1/namespaces/kube-dash/services/kube-dash-kubernetes-dashboard:http/proxy/"
	@kubectl proxy --port 8002

health-check:
	curl -H Host:'central-directory.local' http://${CLUSTER_IP}/health



.PHONY: switch switch-dev swich-prod env