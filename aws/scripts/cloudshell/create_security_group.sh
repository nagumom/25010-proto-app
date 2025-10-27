#!/bin/bash

source ../product_env.sh

# get ids
VPC_ID=`aws ec2 describe-vpcs --filters "Name=tag:Name, Values=${VPC_TAG}" --query "Vpcs[].[VpcId]" --output text`

# create security groups
## for ALB
aws ec2 create-security-group --vpc-id ${VPC_ID} --group-name "${SECURITY_GROUP_FOR_ALB_NAME}" \
  --tag-specifications "ResourceType=security-group, Tags=[{Key=Name, Value=${SECURITY_GROUP_FOR_ALB_NAME}}]" \
  --description "Security group for alb"
## for public subnet
aws ec2 create-security-group --vpc-id ${VPC_ID} --group-name "${SECURITY_GROUP_FOR_PUBLIC_SUBNET_NAME}" \
  --tag-specifications "ResourceType=security-group, Tags=[{Key=Name, Value=${SECURITY_GROUP_FOR_PUBLIC_SUBNET_NAME}}]" \
  --description "Security group for public subnet"
## for private subnet
aws ec2 create-security-group --vpc-id ${VPC_ID} --group-name "${SECURITY_GROUP_FOR_PRIVATE_SUBNET_NAME}" \
  --tag-specifications "ResourceType=security-group, Tags=[{Key=Name, Value=${SECURITY_GROUP_FOR_PRIVATE_SUBNET_NAME}}]" \
  --description "Security group for public subnet"

# security group config
ALB_SG_ID=`aws ec2 describe-security-groups --filters "Name=vpc-id, Values=${VPC_ID}" --filters "Name=group-name, Values=${SECURITY_GROUP_FOR_ALB_NAME}" --query "SecurityGroups[].GroupId" --output text`
PUBLIC_SG_ID=`aws ec2 describe-security-groups --filters "Name=vpc-id, Values=${VPC_ID}" --filters "Name=group-name, Values=${SECURITY_GROUP_FOR_PUBLIC_SUBNET_NAME}" --query "SecurityGroups[].GroupId" --output text`
PRIVATE_SG_ID=`aws ec2 describe-security-groups --filters "Name=vpc-id, Values=${VPC_ID}" --filters "Name=group-name, Values=${SECURITY_GROUP_FOR_PRIVATE_SUBNET_NAME}" --query "SecurityGroups[].GroupId" --output text`
aws ec2 authorize-security-group-ingress --group-id ${ALB_SG_ID}    --protocol tcp --port 80   --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${ALB_SG_ID}    --protocol tcp --port 443  --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id ${PUBLIC_SG_ID} --protocol tcp --port 80   --source-group ${ALB_SG_ID}
aws ec2 authorize-security-group-ingress --group-id ${PUBLIC_SG_ID} --protocol tcp --port 3000 --source-group ${ALB_SG_ID}

# create alb
# ToDo: consider sticky sessions
SUBNET_PUBLIC_1A_ID=`aws ec2 describe-subnets --filter "Name=vpc-id, Values=${VPC_ID}" --filter "Name=tag:Name, Values=${SUBNET_PUBLIC_1A_TAG}" --query "Subnets[].[SubnetId]" --output text`
SUBNET_PUBLIC_1C_ID=`aws ec2 describe-subnets --filter "Name=vpc-id, Values=${VPC_ID}" --filter "Name=tag:Name, Values=${SUBNET_PUBLIC_1C_TAG}" --query "Subnets[].[SubnetId]" --output text`
## for development
aws elbv2 create-load-balancer \
  --name ${ALB_FOR_DEVELOPMENT} \
  --subnets ${SUBNET_PUBLIC_1A_ID} ${SUBNET_PUBLIC_1C_ID} \
  --security-groups ${ALB_SG_ID} \
  --tags Key=Name,Value=${ALB_FOR_DEVELOPMENT}
## for app
aws elbv2 create-load-balancer \
  --name ${ALB_FOR_APPLICATION} \
  --subnets ${SUBNET_PUBLIC_1A_ID} ${SUBNET_PUBLIC_1C_ID} \
  --security-groups ${ALB_SG_ID} \
  --tags Key=Name,Value=${ALB_FOR_APPLICATION}
