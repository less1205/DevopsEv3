#!/bin/bash

set -e

CLUSTER_NAME="ep3-devops"

ROLE=$(aws iam list-roles \
  --query "Roles[?contains(RoleName,'LabEksClusterRole')].Arn" \
  --output text)

SUBNETS=$(aws ec2 describe-subnets \
  --query "Subnets[?AvailabilityZone!='us-east-1e'].[SubnetId]" \
  --output text)

SUBNET1=$(echo $SUBNETS | awk '{print $1}')
SUBNET2=$(echo $SUBNETS | awk '{print $2}')

echo "Role: $ROLE"
echo "Subnet1: $SUBNET1"
echo "Subnet2: $SUBNET2"

aws eks create-cluster \
  --name $CLUSTER_NAME \
  --role-arn "$ROLE" \
  --resources-vpc-config subnetIds=$SUBNET1,$SUBNET2

aws eks wait cluster-active   --name ep3-devops

aws eks describe-cluster   --name ep3-devops   --query 'cluster.status'
