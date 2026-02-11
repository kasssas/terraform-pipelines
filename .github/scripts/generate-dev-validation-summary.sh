#!/bin/bash
# Generate development validation summary for GitHub Actions

set -e

FMT_OUTCOME=$1
INIT_OUTCOME=$2
VALIDATE_OUTCOME=$3
PLAN_OUTCOME=$4

echo "## Development Validation Results" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

echo "### Format Check" >> $GITHUB_STEP_SUMMARY
if [ "$FMT_OUTCOME" == "success" ]; then
  echo "✅ Passed - Code is properly formatted" >> $GITHUB_STEP_SUMMARY
else
  echo "❌ Failed - Run 'terraform fmt -recursive' to fix formatting" >> $GITHUB_STEP_SUMMARY
fi

echo "" >> $GITHUB_STEP_SUMMARY
echo "### Initialization" >> $GITHUB_STEP_SUMMARY
if [ "$INIT_OUTCOME" == "success" ]; then
  echo "✅ Passed - Terraform initialized successfully" >> $GITHUB_STEP_SUMMARY
else
  echo "❌ Failed - Check backend configuration" >> $GITHUB_STEP_SUMMARY
fi

echo "" >> $GITHUB_STEP_SUMMARY
echo "### Validation" >> $GITHUB_STEP_SUMMARY
if [ "$VALIDATE_OUTCOME" == "success" ]; then
  echo "✅ Passed - Configuration is valid" >> $GITHUB_STEP_SUMMARY
else
  echo "❌ Failed - Fix syntax errors" >> $GITHUB_STEP_SUMMARY
fi

echo "" >> $GITHUB_STEP_SUMMARY
echo "### Plan" >> $GITHUB_STEP_SUMMARY
if [ "$PLAN_OUTCOME" == "success" ]; then
  echo "✅ Passed - Plan generated successfully" >> $GITHUB_STEP_SUMMARY
else
  echo "⚠️ Warning - Plan had issues (review logs)" >> $GITHUB_STEP_SUMMARY
fi
