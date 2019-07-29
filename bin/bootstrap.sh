#!/bin/bash

WORK_DIR=$(dirname $0)
kubectl.sh create configmap hpcc-config --from-file=${WORK_DIR}/../configmap/hpcc/
kubectl.sh apply -f ${WORK_DIR}/../security/cluster_role.yaml 
