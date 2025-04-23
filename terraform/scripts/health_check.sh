#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOGS_DIR="$PROJECT_ROOT/terraform/logs"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

mkdir -p "$LOGS_DIR"

echo "$TIMESTAMP - Checking staging health..." | tee -a "$LOGS_DIR/health.log"
STAGING_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/)

if [ "$STAGING_HEALTH" == "200" ]; then
  echo "$TIMESTAMP - Staging health check: SUCCESS (HTTP $STAGING_HEALTH)" | tee -a "$LOGS_DIR/health.log"
  STAGING_STATUS="SUCCESS"
else
  echo "$TIMESTAMP - Staging health check: FAILED (HTTP $STAGING_HEALTH)" | tee -a "$LOGS_DIR/health.log"
  STAGING_STATUS="FAILED"
fi

echo "$TIMESTAMP - Checking production health..." | tee -a "$LOGS_DIR/health.log"
PRODUCTION_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)

if [ "$PRODUCTION_HEALTH" == "200" ]; then
  echo "$TIMESTAMP - Production health check: SUCCESS (HTTP $PRODUCTION_HEALTH)" | tee -a "$LOGS_DIR/health.log"
  PRODUCTION_STATUS="SUCCESS"
else
  echo "$TIMESTAMP - Production health check: FAILED (HTTP $PRODUCTION_HEALTH)" | tee -a "$LOGS_DIR/health.log"
  PRODUCTION_STATUS="FAILED"
fi

if [ "$PRODUCTION_STATUS" == "FAILED" ]; then
  exit 1
fi

exit 0