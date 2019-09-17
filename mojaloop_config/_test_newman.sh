#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/.compiled_env
source $DIR/../config/colors.sh

## A script to test out using newman along with the Mojaloop Postman collection to set up a deployment

#set this if you'd like, otherwise maybe default to another folder in this repo?
PATH_TO_POSTMAN_REPO="/Users/lewisdaly/developer/vessels/mojaloop/postman"
COLLECTION="OSS-New-Deployment-FSP-Setup.postman_collection.json"
ENVIRONMENT="environments/Mojaloop-Local.postman_environment.json"

#TODO: configure the enviroment somehow

# Check that newman exists
newman -v > /dev/null 2>&1 || logErr 'newman is not installed. Install newman with `npm install -g newman` and try again'

# Run the collection
newman run ${PATH_TO_POSTMAN_REPO}/${COLLECTION} \
  -e ${PATH_TO_POSTMAN_REPO}/${ENVIRONMENT} \
  --delay-request 10 \
  --bail \
  --env-var HOST_CENTRAL_LEDGER=central-ledger.moja-box.vessels.tech \
  --env-var HOST_ML_API=ml-api-adapter.moja-box.vessels.tech
