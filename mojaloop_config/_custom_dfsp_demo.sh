#!/usr/bin/env bash

##
# Sets up the demo DFSPs for the custom-dfsp demo
#
##

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/.compiled_env
source $DIR/../config/colors.sh

LEWBANK1_INBOUND_HOST=lewbank1.localtunnel.me
BASE_HOST=moja-box.vessels.tech
CENTRAL_LEDGER_HOST=central-ledger.moja-box.vessels.tech
ALS_HOST=account-lookup-service.moja-box.vessels.tech
ALS_HOST_ADMIN=account-lookup-service-admin.moja-box.vessels.tech
SIMULATOR_HOST=simulator.moja-box.vessels.tech


logStep "Registering currency"

curl -X POST \
  http://${BASE_HOST}/participants/Hub/accounts -H 'Content-Type: application/json' \
  -H 'FSPIOP-Source: lewbank1' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "HUB_MULTILATERAL_SETTLEMENT",
  "currency": "'$CURRENCY'"
}'

logStep 'Add Hub Account-HUB_RECONCILIATION'

curl -X POST \
  http://${BASE_HOST}/participants/Hub/accounts \
  -H 'Authorization: Bearer {{BEARER_TOKEN}}' \
  -H 'Content-Type: application/json' \
  -H 'FSPIOP-Source: lewbank1' \
  -H 'Host: central-ledger.local' \
  -d '{
  "type": "HUB_RECONCILIATION",
  "currency": "'$CURRENCY'"
}'


logStep "Creating payerfsp and payeefsp"
 
curl -X POST \
  http://${BASE_HOST}/participants \
  -H 'Host: central-ledger.local' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "lewbank1",
	"currency":"'$CURRENCY'"
}'

curl -X POST \
  http://${BASE_HOST}/participants/lewbank1/initialPositionAndLimits \
  -H 'Host: central-ledger.local' \
  -H 'Content-Type: application/json' \
  -d '{
    "currency": "'$CURRENCY'",
    "limit": {
    	"type": "NET_DEBIT_CAP",
    	"value": 1000
    },
    "initialPosition": 100
  }'


logStep 'Setting up Simulated endpoints for Transfer'

function registerEndpoint {
  DFSP=$1
  DATA=$2

  # logSubStep "Registering DFSP: ${DFSP} with data: ${DATA}"
  curl -X POST \
    http://${BASE_HOST}/participants/${DFSP}/endpoints \
    -H 'Host: central-ledger.local' \
    -H 'Content-Type: application/json' \
    -d "${DATA}"
}

registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_PUT\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/participants/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_PUT_ERROR\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/participants/{{partyIdType}}/{{partyIdentifier}}/error\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_BATCH_PUT\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/participants/{{requestId}}\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTICIPANT_BATCH_PUT_ERROR\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/participants/{{requestId}}/error\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_GET\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/parties/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_PUT\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/parties/{{partyIdType}}/{{partyIdentifier}}\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_PARTIES_PUT_ERROR\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/parties/{{partyIdType}}/{{partyIdentifier}}/error\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_QUOTES\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_POST\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/transfers\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_PUT\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/payerfstransfers/{{transferId}}\" }"
registerEndpoint lewbank1 "{ \"type\": \"FSPIOP_CALLBACK_URL_TRANSFER_ERROR\", \"value\": \"http://${LEWBANK1_INBOUND_HOST}/transfers/{{transferId}}/error\" }"


logStep 'Setting up the MSIDN Oracle'

CURRENT_DATE=`date`
curl -X POST \
  http://${BASE_HOST}/oracles \
  -H 'Accept: application/vnd.interoperability.participants+json;version=1' \
  -H 'Host: account-lookup-service-admin.local' \
  -H 'Content-Type: application/vnd.interoperability.participants+json;version=1.0' \
  -H 'FSPIOP-Source: lewbank1' \
  -H "Date: ${CURRENT_DATE}" \
  -d '{
  "oracleIdType": "MSISDN",
  "endpoint": {
    "value": "'http://${SIMULATOR_HOST}/oracle'",
    "endpointType": "URL"
  },
  "currency": "'${CURRENCY}'",
  "isDefault": true
}'


logStep 'Creating some demo accounts in ALS'

function registerParty {
  DFSP=$1
  MSISN_PATH=$2
  CURRENT_DATE=`date`

  logSubStep "Registering DFSP: ${DFSP} with path: ${MSISN_PATH}"
  curl -X POST \
    http://${BASE_HOST}/participants/${MSISN_PATH} \
    -H 'Content-Type: application/json' \
    -H 'Host: account-lookup-service.local' \
    -H "Date: ${CURRENT_DATE}" \
    -H "FSPIOP-Source: ${DFSP}" \
    -d '{
      "fspId": "'${DFSP}'",
      "currency": "'${CURRENCY}'"
    }'
}

registerParty lewbank1 "MSISDN/61404404404"
registerParty lewbank1 "MSISDN/123456789"
registerParty lewbank1 "MSISDN/987654321"