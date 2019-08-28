#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/.compiled_env
source $DIR/../config/colors.sh

BASE_HOST=moja-box.vessels.tech

getPosition() {
  dfsp=$1
  logSubStep "Getting position for ${dfsp}"

  curl -X GET \
    http://${CLUSTER_IP}/participants/${dfsp}/positions \
    -H 'Host: central-ledger.local'
}

logStep "Getting positions"
getPosition lewbank1
getPosition lewbank2