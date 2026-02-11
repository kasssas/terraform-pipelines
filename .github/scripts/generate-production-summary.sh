#!/bin/bash
# Generate production deployment summary for GitHub Actions

set -e

APPLY_OUTCOME=$1
VPC_ID=$2
EKS_CLUSTER_NAME=$3
EKS_CLUSTER_ENDPOINT=$4
RDS_ENDPOINT=$5
ECR_REPOSITORY_URLS=$6
AWS_REGION=$7

echo "## 🚀 Production Deployment" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

if [ "$APPLY_OUTCOME" == "success" ]; then
  echo "### ✅ Deployment Successful" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "#### Infrastructure Details" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "**Network**" >> $GITHUB_STEP_SUMMARY
  echo "- **VPC ID**: \`$VPC_ID\`" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "**EKS Cluster**" >> $GITHUB_STEP_SUMMARY
  echo "- **Cluster Name**: \`$EKS_CLUSTER_NAME\`" >> $GITHUB_STEP_SUMMARY
  echo "- **Endpoint**: \`$EKS_CLUSTER_ENDPOINT\`" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "**Database**" >> $GITHUB_STEP_SUMMARY
  echo "- **RDS Endpoint**: \`$RDS_ENDPOINT\`" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "**Container Registry**" >> $GITHUB_STEP_SUMMARY
  echo "- **ECR Repositories**: \`$ECR_REPOSITORY_URLS\`" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "#### AWS Console Links" >> $GITHUB_STEP_SUMMARY
  echo "- [VPC Dashboard](https://console.aws.amazon.com/vpc)" >> $GITHUB_STEP_SUMMARY
  echo "- [EKS Dashboard](https://console.aws.amazon.com/eks)" >> $GITHUB_STEP_SUMMARY
  echo "- [RDS Dashboard](https://console.aws.amazon.com/rds)" >> $GITHUB_STEP_SUMMARY
  echo "- [ECR Dashboard](https://console.aws.amazon.com/ecr)" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "#### Next Steps" >> $GITHUB_STEP_SUMMARY
  echo "1. Verify resources in AWS Console" >> $GITHUB_STEP_SUMMARY
  echo "2. Configure kubectl: \`aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION\`" >> $GITHUB_STEP_SUMMARY
  echo "3. Verify cluster access: \`kubectl get nodes\`" >> $GITHUB_STEP_SUMMARY
else
  echo "### ❌ Deployment Failed" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "Please review the logs above for error details." >> $GITHUB_STEP_SUMMARY
fi
