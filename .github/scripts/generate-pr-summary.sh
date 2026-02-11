#!/bin/bash
# Generate PR review summary for GitHub Actions

set -e

VALIDATE_OUTCOME=$1
CHECKOV_OUTCOME=$2
PLAN_OUTCOME=$3

echo "## Pull Request Review Summary" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

echo "### Terraform Validation" >> $GITHUB_STEP_SUMMARY
if [ "$VALIDATE_OUTCOME" == "success" ]; then
  echo "✅ Configuration is valid" >> $GITHUB_STEP_SUMMARY
else
  echo "❌ Validation failed" >> $GITHUB_STEP_SUMMARY
fi

# tfsec results are separate, this handles checkov
echo "" >> $GITHUB_STEP_SUMMARY
echo "### Security Scan (Checkov)" >> $GITHUB_STEP_SUMMARY
if [ "$CHECKOV_OUTCOME" == "success" ]; then
  echo "✅ No security issues detected" >> $GITHUB_STEP_SUMMARY
else
  echo "⚠️ Security issues found - download HTML report from artifacts for detailed analysis" >> $GITHUB_STEP_SUMMARY
fi

echo "" >> $GITHUB_STEP_SUMMARY
echo "### Terraform Plan" >> $GITHUB_STEP_SUMMARY
if [ "$PLAN_OUTCOME" == "success" ]; then
  echo "✅ Plan generated successfully" >> $GITHUB_STEP_SUMMARY
  echo "" >> $GITHUB_STEP_SUMMARY
  echo "Download the plan artifact to review changes before merging." >> $GITHUB_STEP_SUMMARY
else
  echo "❌ Plan generation failed" >> $GITHUB_STEP_SUMMARY
fi
