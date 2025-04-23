#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
JAR_FILE="$PROJECT_ROOT/demo/target/calculator-0.0.1-SNAPSHOT.jar"
STAGING_DIR="$PROJECT_ROOT/terraform/staging"

echo "Deploying application to staging..."

if [ ! -f "$JAR_FILE" ]; then
  echo "JAR file not found at $JAR_FILE. Exiting."
  exit 1
fi

cp "$JAR_FILE" "$STAGING_DIR/"

cat > "$STAGING_DIR/start.sh" << 'EOF'
#!/bin/bash
nohup java -jar calculator-0.0.1-SNAPSHOT.jar --server.port=8081 > app.log 2>&1 &
echo $! > app.pid
echo "Application started on port 8081. PID: $(cat app.pid)"
EOF

cat > "$STAGING_DIR/stop.sh" << 'EOF'
#!/bin/bash
if [ -f app.pid ]; then
  PID=$(cat app.pid)
  if ps -p $PID > /dev/null; then
    kill $PID
    rm app.pid
    echo "Application stopped."
  else
    echo "No running process found with PID: $PID"
  fi
else
  echo "No application running."
fi
EOF

chmod +x "$STAGING_DIR/start.sh"
chmod +x "$STAGING_DIR/stop.sh"

if [ -f "$STAGING_DIR/app.pid" ]; then
  echo "Stopping existing staging instance..."
  cd "$STAGING_DIR" && ./stop.sh
fi

echo "Starting staging instance..."
cd "$STAGING_DIR" && ./start.sh

echo "Deployment to staging completed."
