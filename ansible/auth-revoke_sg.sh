#!/bin/bash
set -euo pipefail

MY_IP=$(curl -s ifconfig.me)/32
SG_ID=sg-0f74ce185723969ee
REGION=eu-central-1

echo "[INFO] Current IP: $MY_IP"
echo "[INFO] Security Group: $SG_ID"
echo "[INFO] Region: $REGION"

echo "[INFO] Revoking existing SSH rules..."
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --region $REGION \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`22\`].IpRanges[].CidrIp" \
  --output text | while read ip; do
    [ -n "$ip" ] && aws ec2 revoke-security-group-ingress \
      --group-id $SG_ID \
      --protocol tcp \
      --port 22 \
      --cidr $ip \
      --region $REGION || true
done
echo "[INFO] Old rules revoked."

echo "[INFO] Authorizing new IP..."
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP \
  --region $REGION
echo "[INFO] New rule added."

echo "[INFO] Current SSH rules:"
aws ec2 describe-security-groups \
  --group-ids $SG_ID \
  --region $REGION \
  --query "SecurityGroups[0].IpPermissions[?FromPort==\`22\`].IpRanges[].CidrIp" \
  --output text

