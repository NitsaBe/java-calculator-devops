#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
STAGING_DIR="$PROJECT_ROOT/terraform/staging"
PRODUCTION_DIR="$PROJECT_ROOT/terraform/production"
BACKUP_DIR="$PROJECT_ROOT/terraform/backup"

echo "Promoting application to production..."

mkdir -p "$BACKUP_DIR"

if [ -f "$PRODUCTION_DIR/calculator-0.0.1-SNAPSHOT.jar" ]; then
  echo "Backing up current production..."
  rm -rf "$BACKUP_DIR"/*
  cp -r "$PRODUCTION_DIR"/* "$BACKUP_DIR/"
fi

if [ -f "$PRODUCTION_DIR/app.pid" ]; then
  echo "Stopping production instance..."
  cd "$PRODUCTION_DIR" && ./stop.sh
fi

echo "Copying from staging to production..."
cp "$STAGING_DIR/calculator-0.0.1-SNAPSHOT.jar" "$PRODUCTION_DIR/"

cat > "$PRODUCTION_DIR/start.sh" << 'EOF'
#!/bin/bash
nohup java -jar calculator-0.0.1-SNAPSHOT.jar --server.port=8080 > app.log 2>&1 &
echo $! > app.pid
echo "Application started on port 8080. PID: $(cat app.pid)"
EOF

cat > "$PRODUCTION_DIR/stop.sh" << 'EOF'
#!/bin/bash
if [ -f app.pid ]; then
  PID=$(cat app.pid)
  kill $PID
  rm app.pid
  echo "Application stopped."
else
  echo "No application running."
fi
EOF

chmod +x "$PRODUCTION_DIR/start.sh"
chmod +x "$PRODUCTION_DIR/stop.sh"

# Start production
echo "Starting production instance..."
cd "$PRODUCTION_DIR" && ./start.sh

echo "Promotion to production completed."