#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/colors.sh

TF_VAR_lb_public_ip=`make print-lb-ip`

if [ -z ${TF_VAR_lb_public_ip} ]; then
  echo 'TF_VAR_lb_public_ip not set. Please wait for the gcp load balancer to be up and running and try again'
  exit 1
fi

echo "Found load balancer ip: ${TF_VAR_lb_public_ip}"

sed -i "s/TF_VAR_lb_public_ip=.*$/TF_VAR_lb_public_ip=${TF_VAR_lb_public_ip}/g" ${DIR}/gcp.private.sh
#CLUSTER_IP is an old holdover to the manual method of setting the CLUSTER_IP
sed -i '' "s/CLUSTER_IP=.*$/CLUSTER_IP=${TF_VAR_lb_public_ip}/g" ${DIR}/gcp.private.sh