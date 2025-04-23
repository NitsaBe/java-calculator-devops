#!/bin/bash

# This script automates the entire deployment process
# It should be executed after the application is built

# Get directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$TERRAFORM_DIR")"

echo "===== Starting Automated Deployment ====="

# 1. Build the application with Maven if not already built
if [ ! -f "$PROJECT_ROOT/target/calculator-0.0.1-SNAPSHOT.jar" ]; then
  echo "Building application with Maven..."
  cd "$PROJECT_ROOT"
  mvn clean package -DskipTests
  if [ $? -ne 0 ]; then
    echo "Maven build failed. Exiting."
    exit 1
  fi
else
  echo "Using existing JAR file."
fi

# 2. Apply Terraform configuration
echo "Applying Terraform configuration..."
cd "$TERRAFORM_DIR"
terraform init
terraform apply -auto-approve

if [ $? -ne 0 ]; then
  echo "Terraform apply failed. Exiting."
  exit 1
fi

# 3. Deploy to staging
echo "Deploying to staging..."
"$SCRIPT_DIR/deploy.sh"

if [ $? -ne 0 ]; then
  echo "Deployment to staging failed. Exiting."
  exit 1
fi

# 4. Wait a moment before promoting
echo "Waiting 5 seconds before promotion to production..."
sleep 5

# 5. Promote to production
echo "Promoting to production..."
"$SCRIPT_DIR/promote_to_production.sh"

if [ $? -ne 0 ]; then
  echo "Promotion to production failed. Exiting."
  exit 1
fi

# 6. Run health check
echo "Running health check..."
"$SCRIPT_DIR/health_check.sh"

if [ $? -ne 0 ]; then
  echo "Health check failed. Rolling back..."
  "$SCRIPT_DIR/rollback.sh"
  echo "Rollback completed."
  exit 1
fi

echo "===== Deployment Successfully Completed! ====="
echo "Application is now running in production."