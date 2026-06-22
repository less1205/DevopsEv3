#!/bin/bash

set -e

CLUSTER_NAME="ep3-devops"
NODEGROUP_NAME="workers"

echo "Buscando Node Role..."

NODE_ROLE=$(aws iam list-roles \
  --query "Roles[?contains(RoleName,'LabEksNodeRole')].Arn" \
  --output text)

if [ -z "$NODE_ROLE" ]; then
  echo "No se encontró LabEksNodeRole"
  exit 1
fi

echo "Node Role:"
echo "$NODE_ROLE"

echo ""
echo "Buscando subredes válidas..."

SUBNETS=$(aws ec2 describe-subnets \
  --query "Subnets[?AvailabilityZone!='us-east-1e'].[SubnetId]" \
  --output text)

SUBNET1=$(echo $SUBNETS | awk '{print $1}')
SUBNET2=$(echo $SUBNETS | awk '{print $2}')

echo "Subnet1: $SUBNET1"
echo "Subnet2: $SUBNET2"

echo ""
echo "Creando Node Group..."

aws eks create-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --node-role "$NODE_ROLE" \
  --subnets "$SUBNET1" "$SUBNET2" \
  --instance-types t3.medium \
  --scaling-config minSize=1,maxSize=2,desiredSize=2

echo ""
echo "Node Group enviado a creación."
aws eks wait nodegroup-active \
  --cluster-name ep3-devops \
  --nodegroup-name workers

aws eks update-kubeconfig \
  --region us-east-1 \
  --name ep3-devops

kubectl get nodes