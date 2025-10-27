#!/bin/bash

source ../define_resource_names.sh

# create repository
$ aws ecr create-repository --repository-name ${REPOSITORY_FOR_APP_NAME}

# create cluster
$ aws ecs create-cluster --cluster-name ${CLUSTER_FOR_APP_NAME}
