#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/colors.sh

TF_VAR_lb_public_ip=`make print-lb-ip`
logNote "LoadBalancer IP is: ${TF_VAR_lb_public_ip}"

sed -i '' "s/TF_VAR_lb_public_ip=.*$/TF_VAR_lb_public_ip=${TF_VAR_lb_public_ip}/g" ${DIR}/gcp.private.sh
#CLUSTER_IP is an old holdover to the manual method of setting the CLUSTER_IP
sed -i '' "s/CLUSTER_IP=.*$/CLUSTER_IP=${TF_VAR_lb_public_ip}/g" ${DIR}/gcp.private.sh