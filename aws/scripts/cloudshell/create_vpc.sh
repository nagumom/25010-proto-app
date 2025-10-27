#!/bin/bash

source ../product_env.sh

# create vpc
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications "ResourceType=vpc, Tags=[{Key=Name, Value=${VPC_TAG}}]" --no-cli-pager
VPC_ID=`aws ec2 describe-vpcs --filters "Name=tag:Name, Values=${VPC_TAG}" --query "Vpcs[].[VpcId]" --output text`
echo "vpc created. VpcId: ${VPC_ID}"
#aws ec2 describe-vpcs --vpc-ids ${VPC_ID}

# create subnet
aws ec2 create-subnet --vpc-id ${VPC_ID} --availability-zone ${AZ_A} --cidr-block 10.0.11.0/24 --no-cli-pager \
  --tag-specifications "ResourceType=subnet, Tags=[{Key=Name, Value=${SUBNET_PUBLIC_1A_TAG}}]"
aws ec2 create-subnet --vpc-id ${VPC_ID} --availability-zone ${AZ_C} --cidr-block 10.0.12.0/24 --no-cli-pager \
  --tag-specifications "ResourceType=subnet, Tags=[{Key=Name, Value=${SUBNET_PUBLIC_1C_TAG}}]"
aws ec2 create-subnet --vpc-id ${VPC_ID} --availability-zone ${AZ_A} --cidr-block 10.0.21.0/24 --no-cli-pager \
  --tag-specifications "ResourceType=subnet, Tags=[{Key=Name, Value=${SUBNET_PRIVATE_1A_TAG}}]"
aws ec2 create-subnet --vpc-id ${VPC_ID} --availability-zone ${AZ_C} --cidr-block 10.0.22.0/24 --no-cli-pager \
  --tag-specifications "ResourceType=subnet, Tags=[{Key=Name, Value=${SUBNET_PRIVATE_1C_TAG}}]"
aws ec2 describe-subnets --filter "Name=vpc-id, Values=${VPC_ID}" --query "Subnets[].[SubnetId,AvailabilityZone,CidrBlock]" --no-cli-pager

# get created subnet id
SUBNET_PUBLIC_1A_ID=`aws ec2 describe-subnets \
  --filter "Name=vpc-id, Values=${VPC_ID}" \
  --filter "Name=tag:Name, Values=${SUBNET_PUBLIC_1A_TAG}" \
  --query "Subnets[].[SubnetId]" --output text`
SUBNET_PUBLIC_1C_ID=`aws ec2 describe-subnets \
  --filter "Name=vpc-id, Values=${VPC_ID}" \
  --filter "Name=tag:Name, Values=${SUBNET_PUBLIC_1C_TAG}" \
  --query "Subnets[].[SubnetId]" --output text`
SUBNET_PRIVATE_1A_ID=`aws ec2 describe-subnets \
  --filter "Name=vpc-id, Values=${VPC_ID}" \
  --filter "Name=tag:Name, Values=${SUBNET_PRIVATE_1A_TAG}" \
  --query "Subnets[].[SubnetId]" --output text`
SUBNET_PRIVATE_1C_ID=`aws ec2 describe-subnets \
  --filter "Name=vpc-id, Values=${VPC_ID}" \
  --filter "Name=tag:Name, Values=${SUBNET_PRIVATE_1C_TAG}" \
  --query "Subnets[].[SubnetId]" --output text`

# create internet gateway
aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway, Tags=[{Key=Name, Value=${IGW_TAG}}]" --no-cli-pager
aws ec2 describe-internet-gateways --filters "Name=tag:Name, Values=${IGW_TAG}" --no-cli-pager
IGW_ID=`aws ec2 describe-internet-gateways --filters "Name=tag:Name, Values=${IGW_TAG}" --query "InternetGateways[].[InternetGatewayId]" --output text`
echo "igw created. InternetGatewayId: ${IGW_ID}"
aws ec2 attach-internet-gateway --internet-gateway-id ${IGW_ID} --vpc-id ${VPC_ID}

# create route tables
## public route table
aws ec2 create-route-table --vpc-id ${VPC_ID} --tag-specifications "ResourceType=route-table, Tags=[{Key=Name, Value=${ROUTE_TABLE_PUBLIC_TAG}}]" --no-cli-pager
RTB_PUBLIC_ID=`aws ec2 describe-route-tables --filters "Name=vpc-id, Values=${VPC_ID}" --filters "Name=tag:Name, Values=${ROUTE_TABLE_PUBLIC_TAG}" --query "RouteTables[].[RouteTableId]" --output text`
echo "route table (public) created. RouteTableId: ${RTB_PUBLIC_ID}"
aws ec2 create-route --route-table-id ${RTB_PUBLIC_ID} --destination-cidr-block 0.0.0.0/0 --gateway-id ${IGW_ID}
#aws ec2 describe-route-tables --filters "Name=route-table-id, Values=${RTB_PUBLIC_ID}" --query "RouteTables[].Routes" --output table --no-cli-pager

## private route table
aws ec2 create-route-table --vpc-id ${VPC_ID} --tag-specifications "ResourceType=route-table, Tags=[{Key=Name, Value=${ROUTE_TABLE_PRIVATE_TAG}}]" --no-cli-pager
RTB_PRIVATE_ID=`aws ec2 describe-route-tables --filters "Name=vpc-id, Values=${VPC_ID}" --filters "Name=tag:Name, Values=${ROUTE_TABLE_PRIVATE_TAG}" --query "RouteTables[].[RouteTableId]" --output text`
echo "route table (private) created. RouteTableId: ${RTB_PRIVATE_ID}"
#aws ec2 describe-route-tables --filters "Name=route-table-id, Values=${RTB_PRIVATE_ID}" --query "RouteTables[].Routes" --output table --no-cli-pager

# associate route table to subnets
aws ec2 associate-route-table --subnet-id ${SUBNET_PUBLIC_1A_ID} --route-table-id ${RTB_PUBLIC_ID}
aws ec2 associate-route-table --subnet-id ${SUBNET_PUBLIC_1C_ID} --route-table-id ${RTB_PUBLIC_ID}
aws ec2 associate-route-table --subnet-id ${SUBNET_PRIVATE_1A_ID} --route-table-id ${RTB_PRIVATE_ID}
aws ec2 associate-route-table --subnet-id ${SUBNET_PRIVATE_1C_ID} --route-table-id ${RTB_PRIVATE_ID}

# public subnet automatically assign globl ip address
#aws ec2 modify-subnet-attribute --subnet-id ${SUBNET_PUBLIC_1A_ID} --map-public-ip-on-launch
#aws ec2 modify-subnet-attribute --subnet-id ${SUBNET_PUBLIC_1C_ID} --map-public-ip-on-launch
