terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

resource "local_file" "production_startup" {
  content = <<-EOT
    #!/bin/bash
    cd "$(dirname "$0")"
    java -jar calculator-app-0.0.1-SNAPSHOT.jar --server.port=8081 > ../logs/production.log 2>&1 &
    echo $! > app.pid
    echo "Production application started on port 8081. PID: $(cat app.pid)"
  EOT
  filename = "../deploy/production/start.sh"
  file_permission = "0755"
}

resource "local_file" "blue_green_script" {
  content = <<-EOT
    #!/bin/bash
    DEPLOY_DIR="../deploy"
    BLUE_DIR="$DEPLOY_DIR/blue"
    GREEN_DIR="$DEPLOY_DIR/green"
    PROD_LINK="$DEPLOY_DIR/production"
    JAR_FILE="calculator-app-0.0.1-SNAPSHOT.jar"

    # Create blue/green directories if they don't exist
    mkdir -p "$BLUE_DIR" "$GREEN_DIR"

    # Determine current environment
    if [ -L "$PROD_LINK" ]; then
      current=$(readlink "$PROD_LINK")
      if [[ "$current" == *"blue"* ]]; then
        CURRENT="blue"
        TARGET="green"
      else
        CURRENT="green"
        TARGET="blue"
      fi
    else
      CURRENT="none"
      TARGET="blue"
    fi

    echo "Current environment: $CURRENT"
    echo "Target environment: $TARGET"

    # Copy JAR to target environment
    cp "$DEPLOY_DIR/staging/$JAR_FILE" "$DEPLOY_DIR/$TARGET/"

    # Copy startup script
    cp "$DEPLOY_DIR/staging/start.sh" "$DEPLOY_DIR/$TARGET/"
    cp "$DEPLOY_DIR/staging/stop.sh" "$DEPLOY_DIR/$TARGET/"

    # Stop current environment if running
    if [ "$CURRENT" != "none" ]; then
      if [ -f "$DEPLOY_DIR/$CURRENT/app.pid" ]; then
        echo "Stopping current environment ($CURRENT)..."
        bash "$DEPLOY_DIR/$CURRENT/stop.sh"
      fi
    fi

    # Start new environment
    echo "Starting new environment ($TARGET)..."
    cd "$DEPLOY_DIR/$TARGET"
    bash "./start.sh"

    # Wait for application to start
    echo "Waiting for application to start..."
    sleep 5

    # Health check
    if curl -s --head "http://localhost:8081" | grep "200 OK" > /dev/null; then
      echo "Application started successfully. Switching production link..."
      # Update production symlink
      rm -f "$PROD_LINK"
      ln -s "$DEPLOY_DIR/$TARGET" "$PROD_LINK"
      echo "Deployment complete. New environment is $TARGET"
    else
      echo "Application failed to start. Rolling back..."
      # Stop failed deployment
      bash "$DEPLOY_DIR/$TARGET/stop.sh"

      # Restart previous environment if it existed
      if [ "$CURRENT" != "none" ]; then
        echo "Restarting previous environment ($CURRENT)..."
        cd "$DEPLOY_DIR/$CURRENT"
        bash "./start.sh"
        # Ensure the link points to the correct environment
        rm -f "$PROD_LINK"
        ln -s "$DEPLOY_DIR/$CURRENT" "$PROD_LINK"
      fi
      echo "Rollback complete."
      exit 1
    fi
  EOT
  filename = "../deploy/blue_green_deploy.sh"
  file_permission = "0755"
}

resource "local_file" "rollback_script" {
  content = <<-EOT
    #!/bin/bash
    DEPLOY_DIR="../deploy"
    BLUE_DIR="$DEPLOY_DIR/blue"
    GREEN_DIR="$DEPLOY_DIR/green"
    PROD_LINK="$DEPLOY_DIR/production"

    # Determine current environment
    if [ -L "$PROD_LINK" ]; then
      current=$(readlink "$PROD_LINK")
      if [[ "$current" == *"blue"* ]]; then
        CURRENT="blue"
        PREVIOUS="green"
      else
        CURRENT="green"
        PREVIOUS="blue"
      fi

      # Check if previous environment exists
      if [ ! -d "$DEPLOY_DIR/$PREVIOUS" ] || [ ! -f "$DEPLOY_DIR/$PREVIOUS/start.sh" ]; then
        echo "No previous environment to roll back to."
        exit 1
      fi

      # Stop current environment
      echo "Stopping current environment ($CURRENT)..."
      bash "$DEPLOY_DIR/$CURRENT/stop.sh"

      # Start previous environment
      echo "Starting previous environment ($PREVIOUS)..."
      cd "$DEPLOY_DIR/$PREVIOUS"
      bash "./start.sh"

      # Update production symlink
      rm -f "$PROD_LINK"
      ln -s "$DEPLOY_DIR/$PREVIOUS" "$PROD_LINK"

      echo "Rollback complete. Current environment is now $PREVIOUS"
    else
      echo "No current deployment found. Cannot roll back."
      exit 1
    fi
  EOT
  filename = "../deploy/rollback.sh"
  file_permission = "0755"
}

resource "local_file" "automated_health_monitor" {
  content         = <<-EOT
    #!/bin/bash
    DEPLOY_DIR="../deploy"
    LOG_FILE="$DEPLOY_DIR/logs/monitor.log"
    CHECK_INTERVAL=60  # seconds

    echo "Starting health monitor at $(date)" >> $LOG_FILE

    while true; do
      # Check if production is running
      if ! curl -s --head "http://localhost:8081" | grep "200 OK" > /dev/null; then
        echo "$(date) - ALERT: Production is DOWN. Initiating automatic rollback..." >> $LOG_FILE
        bash $DEPLOY_DIR/rollback.sh >> $LOG_FILE 2>&1

        # Check if rollback was successful
        if curl -s --head "http://localhost:8081" | grep "200 OK" > /dev/null; then
          echo "$(date) - Rollback successful. Production is now UP." >> $LOG_FILE
        else
          echo "$(date) - CRITICAL: Rollback failed. Production is still DOWN." >> $LOG_FILE
        fi
      else
        echo "$(date) - Production is UP and running normally." >> $LOG_FILE
      fi

      sleep $CHECK_INTERVAL
    done
  EOT
  filename        = "../deploy/health_monitor.sh"
  file_permission = "0755"
}