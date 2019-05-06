

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
gcloud config set compute/zone asia-southeast1

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
```

