#!/bin/bash

if [ -z ${PRODUCT_CODE} ] || [ -z ${PRODUCT_ENV} ]; then
    echo "PRODUCT_CODE, PRODUCT_ENV is not set."
    exit;
fi

# ecs login
aws ecr get-login-password --region ${AWS_REGION} | docker login \
  --username AWS \
  --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# build container image
PRODUCT_APP_IMAGE_TAG=latest
docker buildx build -t ${PRODUCT_APP_IMAGE_NAME}:${PRODUCT_APP_IMAGE_TAG} --no-cache ../../../app/sample_express/

# push container image
docker tag ${PRODUCT_APP_IMAGE_NAME}:${PRODUCT_APP_IMAGE_TAG} \
  ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_FOR_APP_NAME}:${PRODUCT_APP_IMAGE_TAG}
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_FOR_APP_NAME}:${PRODUCT_APP_IMAGE_TAG}
