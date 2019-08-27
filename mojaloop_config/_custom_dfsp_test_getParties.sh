#!/usr/bin/env bash


# Just a script to test that the getParties is working

curl -X GET \
  http://account-lookup-service.moja-box.vessels.tech/parties/MSISDN/61404404404 \
  -H 'Accept: */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/json' \
  -H 'Date: Fri, 21 Dec 2018 12:17:01 GMT' \
  -H 'FSPIOP-Source: lewbank1'