# Notes

_misc notes for ML Deployment_

## Hosts

For the postman examples, we set all of the hosts to the Kubernetes public IP, and use the `Host` header which the Nginx ingress router uses to send our requests to the right services.

This is because Postman ignores our `/etc/hosts` file.

```
service                    host:
HOST_CENTRAL_LEDGER        central-ledger.local
HOST_CENTRAL_DIRECTORY     central-directory.local


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