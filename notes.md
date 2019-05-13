# Notes

_misc notes for ML Deployment_

## Hosts

For the postman examples, we set all of the hosts to the Kubernetes public IP, and use the `Host` header which the Nginx ingress router uses to send our requests to the right services.

This is because Postman ignores our `/etc/hosts` file.

```
service                    host:
HOST_CENTRAL_LEDGER        central-ledger.local
HOST_CENTRAL_DIRECTORY     central-directory.local
HOST_MOJALOOP              interop-switch.local
HOST_ML_API                ml-api-adapter.local


Others?

chart-example.local
central-ledger-admin-transfer.local
central-ledger.local
central-ledger-transfer-prepare.local
central-ledger-transfer-position.local
central-ledger-transfer-fulfil.local
central-ledger-timeout.local
central-directory.local
central-end-user-registry.local
email-notifier.local
central-kms.local
interop-switch.local
ml-api-adapter.local
ml-api-adapter-notification.local
cluster.local
central-settlement.local
forensic-logging-sidecar.local
central-ledger-transfer-get.local
mock-pathfinder.local
central-event-processor.local


Ingress:
dev-centraldirectory                         central-directory.local                 35.240.237.242  80     143m
dev-centraleventprocessor                    central-event-processor.local           35.240.237.242  80     143m
dev-centralledger-handler-admin-transfer     central-ledger-admin-transfer.local     35.240.237.242  80     143m
dev-centralledger-handler-timeout            central-ledger-timeout.local            35.240.237.242  80     143m
dev-centralledger-handler-transfer-fulfil    central-ledger-transfer-fulfil.local    35.240.237.242  80     143m
dev-centralledger-handler-transfer-get       central-ledger-transfer-get.local       35.240.237.242  80     143m
dev-centralledger-handler-transfer-position  central-ledger-transfer-position.local  35.240.237.242  80     143m
dev-centralledger-handler-transfer-prepare   central-ledger-transfer-prepare.local   35.240.237.242  80     143m
dev-centralledger-service                    central-ledger.local                    35.240.237.242  80     143m
dev-centralkms                               central-kms.local                       35.240.237.242  80     143m
dev-centralsettlement                        central-settlement.local                35.240.237.242  80     143m
dev-emailnotifier                            email-notifier.local                    35.240.237.242  80     143m
dev-interop-switch                           interop-switch.local                    35.240.237.242  80     143m
dev-ml-api-adapter-handler-notification      ml-api-adapter-notification.local       35.240.237.242  80     143m
dev-ml-api-adapter-service                   ml-api-adapter.local                    35.240.237.242  80     143m

```

## Get positions:

```bash
curl -X GET \
  http://35.247.170.113/participants/payerfsp/positions \
  -H 'Host: central-ledger.local' 
```


```bash
curl -X GET \
  http://35.247.170.113/participants/payeefsp/positions \
  -H 'Host: central-ledger.local'
```


## Initiate a transfer:
```bash
curl -X POST \
  http://35.247.170.113/transfers \
  -H 'Accept: application/vnd.interoperability.quotes+json;version=1' \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/vnd.interoperability.quotes+json;version=1.0' \
  -H 'Date: Tue, 07 May 2019 05:19:37 GMT' \
  -H 'FSPIOP-Destination: payeefsp' \
  -H 'FSPIOP-Source: payerfsp' \
  -H 'Host: ml-api-adapter.local' \
  -H 'Postman-Token: 49c05c5e-41b8-44ab-a269-c233221456f2' \
  -H 'cache-control: no-cache' \
  -d '{
 "transferId": "47d5c060-9115-4700-9f6e-30f9d18eac7a",
 "payeeFsp": "payeefsp",
 "payerFsp": "payerfsp",
 "amount": {
   "amount": "100",
   "currency": "AUD"
 },
 "ilpPacket": "AQAAAAAAAABkEGcuZXdwMjEuaWQuODAwMjCCAhd7InRyYW5zYWN0aW9uSWQiOiJmODU0NzdkYi0xMzVkLTRlMDgtYThiNy0xMmIyMmQ4MmMwZDYiLCJxdW90ZUlkIjoiOWU2NGYzMjEtYzMyNC00ZDI0LTg5MmYtYzQ3ZWY0ZThkZTkxIiwicGF5ZWUiOnsicGFydHlJZEluZm8iOnsicGFydHlJZFR5cGUiOiJNU0lTRE4iLCJwYXJ0eUlkZW50aWZpZXIiOiIyNTYxMjM0NTYiLCJmc3BJZCI6IjIxIn19LCJwYXllciI6eyJwYXJ0eUlkSW5mbyI6eyJwYXJ0eUlkVHlwZSI6Ik1TSVNETiIsInBhcnR5SWRlbnRpZmllciI6IjI1NjIwMTAwMDAxIiwiZnNwSWQiOiIyMCJ9LCJwZXJzb25hbEluZm8iOnsiY29tcGxleE5hbWUiOnsiZmlyc3ROYW1lIjoiTWF0cyIsImxhc3ROYW1lIjoiSGFnbWFuIn0sImRhdGVPZkJpcnRoIjoiMTk4My0xMC0yNSJ9fSwiYW1vdW50Ijp7ImFtb3VudCI6IjEwMCIsImN1cnJlbmN5IjoiVVNEIn0sInRyYW5zYWN0aW9uVHlwZSI6eyJzY2VuYXJpbyI6IlRSQU5TRkVSIiwiaW5pdGlhdG9yIjoiUEFZRVIiLCJpbml0aWF0b3JUeXBlIjoiQ09OU1VNRVIifSwibm90ZSI6ImhlaiJ9",
 "condition": "otTwY9oJKLBrWmLI4h0FEw4ksdZtoAkX3qOVAygUlTI",
 "expiration": "2018-11-08T21:31:00.534+01:00"
}'
```


## No currency

When trying to create a new FSP, I keep on getting the error:

```
{
  "id": "BadRequestError",
  "message": "Hub reconciliation account for the specified currency does not exist"
}
```

An example request is:
```bash
curl -X POST \
  http://35.247.170.113/participants \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -H 'Host: central-ledger.local' \
  -H 'Postman-Token: 78413ea3-1a32-4f21-8f3d-94cbf42b4e8d' \
  -H 'cache-control: no-cache' \
  -d '{
    "name": "payerfsp",
	"currency":"USD"
}'
```

This was solved by running the scripts in `./mojaloop_config/00_set_up_env.sh`



### Trying to get to interop-switch

Using the Host header doesn't seem to work

```
curl -H Host:'interop-switch.local' http://35.247.170.113/health
curl -H Host:'interop-switch.local' http://35.247.170.113/interop/switch/v1
```

When we hit `/interop/switch/v1` we do manage to get past the Nginx backend,but get the error: `{ "message": "Resource not found" }`
which appears to be from the interop switch service

I've also tried proxying:

`http://localhost:8002/api/v1/namespaces/mojaloop/services/dev-interop-switch/proxy`

We don't know enough about how the mojaloop proxying thing works.


Found the docs endpoints:
http://localhost:8088/switch/v1/documentation/index.html
http://localhost:8088/switch/v1/documentation/interop-switch.yaml

With `/etc/hosts` setup:
