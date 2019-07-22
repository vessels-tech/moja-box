#!/usr/bin/env bash

##
# Sets up the demo DFSPs
#
##

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/.compiled_env

echo 'Creating payerfsp and payeefsp'

# curl -X POST \
#   http://${CLUSTER_IP}/participants \
#   -H 'Cache-Control: no-cache' \
#   -H 'Content-Type: application/json' \
#   -H 'Host: central-ledger.local' \
#   -d '{
#     "name": "payerfsp",
# 	"currency":"'$CURRENCY'"
# }'


# curl -X POST \
#   http://${CLUSTER_IP}/participants/payerfsp/initialPositionAndLimits \
#   -H 'Content-Type: application/json' \
#   -H 'Host: central-ledger.local' \
#   -d '{
#     "currency": "'$CURRENCY'",
#     "limit": {
#     	"type": "NET_DEBIT_CAP",
#     	"value": 1000
#     },
#     "initialPosition": 0
#   }'


# curl -X POST \
#   http://${CLUSTER_IP}/participants \
#   -H 'Cache-Control: no-cache' \
#   -H 'Content-Type: application/json' \
#   -H 'Host: central-ledger.local' \
#   -d '{
#     "name": "payeefsp",
# 	"currency":"'$CURRENCY'"
# }'


# curl -X POST \
#   http://${CLUSTER_IP}/participants/payeefsp/initialPositionAndLimits \
#   -H 'Cache-Control: no-cache' \
#   -H 'Content-Type: application/json' \
#   -H 'Host: central-ledger.local' \
#   -d '{
#     "currency": "'$CURRENCY'",
#     "limit": {
#     	"type": "NET_DEBIT_CAP",
#     	"value": 1000
#     },
#     "initialPosition": 0
#   }'

echo 'Setting up Simulated endpoints'


# Transfer Endpoints - payerfsp
curl -X POST \
  http://${CLUSTER_IP}/participants/payerfsp/endpoints \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "FSPIOP_CALLBACK_URL_TRANSFER_POST",
  "value": "http://simulator.moja-box.vessels.tech/payerfsp/transfers"
}'

curl -X POST \
  http://${CLUSTER_IP}/participants/payerfsp/endpoints \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "FSPIOP_CALLBACK_URL_TRANSFER_PUT",
  "value": "http://simulator.moja-box.vessels.tech/payerfsp/transfers/{{transferId}}"
}'

curl -X POST \
  http://${CLUSTER_IP}/participants/payerfsp/endpoints \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "FSPIOP_CALLBACK_URL_TRANSFER_ERROR",
  "value": "http://simulator.moja-box.vessels.tech/payerfsp/transfers/{{transferId}}/error"
}'

curl -X POST \
  http://${CLUSTER_IP}/participants/payeefsp/endpoints \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "FSPIOP_CALLBACK_URL_TRANSFER_POST",
  "value": "http://simulator.moja-box.vessels.tech/payerfsp/transfers"
}'

curl -X POST \
  http://${CLUSTER_IP}/participants/payeefsp/endpoints \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "FSPIOP_CALLBACK_URL_TRANSFER_PUT",
  "value": "http://simulator.moja-box.vessels.tech/payerfsp/transfers/{{transferId}}"
}'

curl -X POST \
  http://${CLUSTER_IP}/participants/payeefsp/endpoints \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "FSPIOP_CALLBACK_URL_TRANSFER_ERROR",
  "value": "http://simulator.moja-box.vessels.tech/payerfsp/transfers/{{transferId}}/error"
}'

