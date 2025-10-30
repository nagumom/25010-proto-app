#!/bin/bash

if [ -z ${PRODUCT_CODE} ] || [ -z ${PRODUCT_ENV} ]; then
    echo "PRODUCT_CODE, PRODUCT_ENV is not set."
    exit;
fi

# create repository
$ aws ecr create-repository --repository-name ${REPOSITORY_FOR_APP_NAME}

# create cluster
$ aws ecs create-cluster --cluster-name ${CLUSTER_FOR_APP_NAME}
