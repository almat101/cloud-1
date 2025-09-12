#!/bin/bash

MY_IP=$(curl -s ifconfig.me)/32
SG_ID=sg-0f74ce185723969ee
REGION=eu-central-1


echo my ip: $MY_IP
echo security gruop: $SG_ID
echo region: $REGION


aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP \
  --region $REGION

echo done!
