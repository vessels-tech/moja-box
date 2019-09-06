#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/../config/colors.sh

TF_VAR_lb_public_ip=`make print-lb-ip`

while [ "${TF_VAR_lb_public_ip}" == "" ]; do
  if [ "$WAIT" == "true" ]; then
    logNote "WAIT is true, waiting until ip is available"
  else
    logErr "TF_VAR_lb_public_ip not set. Please wait for the gcp load balancer to be up and running and try again"
    exit 1
  fi

  sleep 4
  TF_VAR_lb_public_ip=`make print-lb-ip`
done

logNote "Found load balancer ip: ${TF_VAR_lb_public_ip}"
perl -pi -e s,TF_VAR_lb_public_ip=.*$,TF_VAR_lb_public_ip=${TF_VAR_lb_public_ip},g ${DIR}/gcp.private.sh
perl -pi -e s,CLUSTER_IP=.*$,CLUSTER_IP=${TF_VAR_lb_public_ip},g ${DIR}/gcp.private.sh