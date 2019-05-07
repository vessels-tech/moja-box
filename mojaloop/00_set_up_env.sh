#!/usr/bin/env bash

##
# Sets up the necessary environment for the ML Environment
#
##

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/.compiled_env




echo 'Step 1: `Add Hub Account-HUB_MULTILATERAL_SETTLEMENT`'

curl -X POST \
  http://${CLUSTER_IP}/participants/Hub/accounts \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Content-Type: application/json' \
  -H 'FSPIOP-Source: payerfsp' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "HUB_MULTILATERAL_SETTLEMENT",
  "currency": "'$CURRENCY'"
}'

echo 'Step 2: `Add Hub Account-HUB_RECONCILIATION`'

curl -X POST \
  http://${CLUSTER_IP}/participants/Hub/accounts \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Content-Type: application/json' \
  -H 'FSPIOP-Source: payerfsp' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "HUB_RECONCILIATION",
  "currency": "'$CURRENCY'"
}'

echo 'Step 3: `Hub Set Endpoint-SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL`'

curl -X POST \
  http://${CLUSTER_IP}/participants/hub/endpoints \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "SETTLEMENT_TRANSFER_POSITION_CHANGE_EMAIL",
  "value": "'${EMAIL_ADDRESS}'"
}'

echo 'Step 4: `Hub Set Endpoint-NET_DEBIT_CAP_ADJUSTMENT_EMAIL`'

curl -X POST \
  http://${CLUSTER_IP}/participants/hub/endpoints \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "NET_DEBIT_CAP_ADJUSTMENT_EMAIL",
  "value": "'$EMAIL_ADDRESS'"
}'

echo 'Step 5: Hub Set Endpoint-NET_DEBIT_CAP_THRESHOLD_BREACH_EMAIL'

curl -X POST \
  http://${CLUSTER_IP}/participants/hub/endpoints \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "NET_DEBIT_CAP_THRESHOLD_BREACH_EMAIL",
  "value": "'$EMAIL_ADDRESS'"
}'

