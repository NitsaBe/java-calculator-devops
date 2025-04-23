#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
PRODUCTION_DIR="$PROJECT_ROOT/terraform/production"
BACKUP_DIR="$PROJECT_ROOT/terraform/backup"

echo "Rolling back to previous production version..."

if [ ! -f "$BACKUP_DIR/calculator-0.0.1-SNAPSHOT.jar" ]; then
  echo "No backup found. Cannot rollback."
  exit 1
fi

if [ -f "$PRODUCTION_DIR/app.pid" ]; then
  echo "Stopping current production instance..."
  cd "$PRODUCTION_DIR" && ./stop.sh
fi

echo "Restoring from backup..."
cp "$BACKUP_DIR/calculator-0.0.1-SNAPSHOT.jar" "$PRODUCTION_DIR/"
cp "$BACKUP_DIR/start.sh" "$PRODUCTION_DIR/"
cp "$BACKUP_DIR/stop.sh" "$PRODUCTION_DIR/"

chmod +x "$PRODUCTION_DIR/start.sh"
chmod +x "$PRODUCTION_DIR/stop.sh"

echo "Starting rolled back production instance..."
cd "$PRODUCTION_DIR" && ./start.sh

echo "Rollback completed."