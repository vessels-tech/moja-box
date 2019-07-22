#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TF_VAR_lb_public_ip=`make print-lb-ip`
sed -i "s/TF_VAR_lb_public_ip=.*$/TF_VAR_lb_public_ip=${TF_VAR_lb_public_ip}/g" ${DIR}/mojaloop.private.sh