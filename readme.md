

## Local Config

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

### Fixing Helm

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
brew install kubernetes-helm
helm init
kubectl -n kube-system get pod | grep tiller

helm repo add mojaloop http://mojaloop.io/helm/repo/
helm install --debug --namespace=mojaloop --name=dev --repo=http://mojaloop.io/helm/repo mojaloop
helm repo update
```

### Testing that ML is up and running

```bash
curl -H Host:'central-directory.mojaloop.vessels.tech' 68.183.247.27/health
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

```





