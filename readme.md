

## Local Config

### GCP

Create a new project in GCP, and download the service.json file

Ref: https://github.com/daaain/terraform-kubernetes-on-gcp/blob/master/docs/gcp.md

- Create a new service account key `default@moja-box.iam.gserviceaccount.com`
  Role: `Project/Editor`

- Click "Create"

- Save .json file to `./config/default.json`
- `echo 'default.json' > .gitignore` to make sure we don't add this to git.


### Install `GCloud` and setup

```bash
brew tap caskroom/cask
brew cask install google-cloud-sdk

gcloud components update
gcloud auth application-default login
gcloud config set compute/location asia-southeast1-a
gcloud config set project moja-box

```

### Install Terraform + Kube CLI

```bash
brew install terraform
brew install kubernetes-cli
brew install kubernetes-helm
```


### Terraform commands

cp ./secrets.auto.tfvars.example ./secrets.auto.tfvars

Init terraform

```bash
cd ./terraform
terraform init -get=true -get-plugins=true

#make chagnes in ./terraform/variables.tf as needed

#now see what will be changed
terraform plan

#deploy
terraform apply
```


### GCloud
Once the cluster is up and running:

```bash
gcloud container clusters list
gcloud container clusters get-credentials moja-box-cluster
```

### Helm setup

```
helm init
```


### Fixing Helm Permissions

```bash
helm list #this should fail be default

#Give helm the necessary permissions to install stuff on the cluster
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade

helm list #should succeed
```

### Running Mojaloop on the Cluster
```bash

kubectl -n kube-system get pod | grep tiller

helm repo add mojaloop http://mojaloop.io/helm/repo/

#run the mojaloop helm charts
helm install --debug --namespace=mojaloop --name=dev --repo=http://mojaloop.io/helm/repo mojaloop
helm repo update


#set up the nginx-ingress
helm --namespace=mojaloop install stable/nginx-ingress --name=nginx
kubectl apply -f ingress-resource.yaml

```

#### edit your /etc/hosts file as follows:

```bash
$ tail /etc/hosts:
...
35.247.170.113	interop-switch.local central-kms.local forensic-logging-sidecar.local central-ledger.local central-end-user-registry.local central-directory.local central-hub.local central-settlement.local ml-api-adapter.local
```

### Installing the Kubernetes Dashboard
```bash
helm install stable/kubernetes-dashboard --namespace kube-dash --name kube-dash \
  --set rbac.clusterAdminRole=true,enableSkipLogin=true,enableInsecureLogin=true
  

#proxy local to allow access
kubectl proxy --port 8002


#open the dashboard
open http://localhost:8002/api/v1/namespaces/kube-dash/services/kube-dash-kubernetes-dashboard:https/proxy/

```

### Testing that ML is up and running

```bash
curl -H Host:'central-directory.local' <cluster_ip_address>/health

#eg
curl -H Host:'central-directory.local' http://35.247.170.113/health
#should print {"status":"OK"}

#you can also go to your browser
open http://central-directory.local/
```

## Configure a Vanilla Mojaloop Deployment

These were taken from the 'OSS New Deployment' Postman collection found [here](https://github.com/mojaloop/postman). I don't exactly know what they do, but after I ran through the first 5 steps, I could add participants (demo DFSPs) as needed.

### Step 1: `Add Hub Account-HUB_MULTILATERAL_SETTLEMENT`

```bash
curl -X POST \
  http://35.247.170.113/participants/Hub/accounts \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Content-Type: application/json' \
  -H 'FSPIOP-Source: payerfsp' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "HUB_MULTILATERAL_SETTLEMENT",
  "currency": "AUD"
}'
```

### Step 2: `Add Hub Account-HUB_RECONCILIATION`

```bash
curl -X POST \
  http://35.247.170.113/participants/Hub/accounts \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Content-Type: application/json' \
  -H 'FSPIOP-Source: payerfsp' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "HUB_RECONCILIATION",
  "currency": "AUD"
}'
```

### Step 3: `Hub Set Endpoint-SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL`

```bash
curl -X POST \
  http://35.247.170.113/participants/hub/endpoints \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL",
  "value": "email@example.com"
}'
```


### Step 4: `Hub Set Endpoint-NET_DEBIT_CAP_ADJUSTMENT_EMAIL`

```bash
curl -X POST \
  http://35.247.170.113/participants/hub/endpoints \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "NET_DEBIT_CAP_ADJUSTMENT_EMAIL",
  "value": "email@example.com"
}'
```


### Step 5: ``

```bash
curl -X POST \
  http://35.247.170.113/participants/Hub/endpoints \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "NET_DEBIT_CAP_THRESHOLD_BREACH_EMAIL",
  "value": "email@example.com"
}'
```


### Step 6: `Create Test FSPs`

```bash
curl -X POST \
  http://35.247.170.113/participants \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "name": "payerfsp",
	"currency":"AUD"
}'


curl -X POST \
  http://35.247.170.113/participants/payerfsp/initialPositionAndLimits \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "currency": "AUD",
    "limit": {
    	"type": "NET_DEBIT_CAP",
    	"value": 1000
    },
    "initialPosition": 0
  }'


curl -X POST \
  http://35.247.170.113/participants \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "name": "payeefsp",
	"currency":"AUD"
}'


curl -X POST \
  http://35.247.170.113/participants/payeefsp/initialPositionAndLimits \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
    "currency": "AUD",
    "limit": {
    	"type": "NET_DEBIT_CAP",
    	"value": 1000
    },
    "initialPosition": 0
  }'


```






## Tearing down a deployment

### Helm

```bash
helm ls --all
helm delete --purge kube-dash toned-joey dev cold-cat honking-pika
```


### Terraform

```bash
cd ./terraform
terraform destroy
```






## Misc

```bash

#list service accounts
kubectl -n kube-system get serviceAccounts

#delete a service account
kubectl -n kube-system delete serviceAccounts tiller

#get cluster role bindings
kubectl -n kube-system get clusterrolebindings

#delete a cluster role binding
kubectl -n kube-system delete clusterrolebindings tiller

#delete a deployment
helm delete kube-dash
helm delete --purge kube-dash

#delete tiller from cluster
kubectl delete deployment tiller-deploy --namespace kube-system

```





