terraform {
  required_version = ">= 1.0.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# Variables
variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "calculator"
}

variable "app_version" {
  description = "Version of the application"
  type        = string
  default     = "0.0.1-SNAPSHOT"
}

variable "production_dir" {
  description = "Directory for production deployment"
  type        = string
  default     = "/opt/calculator-production"
}

variable "staging_dir" {
  description = "Directory for staging deployment"
  type        = string
  default     = "/opt/calculator-staging"
}

variable "jar_file" {
  description = "Path to the JAR file"
  type        = string
  default     = "../target/calculator-0.0.1-SNAPSHOT.jar"
}

# Local directories for deployment
resource "local_file" "production_directory" {
  filename = "${path.module}/scripts/create_production_dir.sh"
  content  = <<-EOT
    #!/bin/bash
    mkdir -p ${var.production_dir}
    chmod 755 ${var.production_dir}
    echo "Production directory created at ${var.production_dir}"
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${self.filename} && ${self.filename}"
  }
}

resource "local_file" "staging_directory" {
  filename = "${path.module}/scripts/create_staging_dir.sh"
  content  = <<-EOT
    #!/bin/bash
    mkdir -p ${var.staging_dir}
    chmod 755 ${var.staging_dir}
    echo "Staging directory created at ${var.staging_dir}"
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${self.filename} && ${self.filename}"
  }
}

# Deployment scripts
resource "local_file" "deploy_script" {
  filename = "${path.module}/scripts/deploy.sh"
  content  = <<-EOT
    #!/bin/bash

    # Check if JAR file exists
    if [ ! -f ${var.jar_file} ]; then
      echo "Error: JAR file not found at ${var.jar_file}"
      exit 1
    fi

    # Copy JAR to staging
    cp ${var.jar_file} ${var.staging_dir}/${var.app_name}.jar
    echo "Application deployed to staging at ${var.staging_dir}/${var.app_name}.jar"

    # Create service file in staging
    cat > ${var.staging_dir}/${var.app_name}.service <<EOF
    [Unit]
    Description=${var.app_name} Service
    After=network.target

    [Service]
    ExecStart=/usr/bin/java -jar ${var.staging_dir}/${var.app_name}.jar
    Restart=always
    User=nobody

    [Install]
    WantedBy=multi-user.target
    EOF

    echo "Created service file in staging"
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }

  depends_on = [
    local_file.staging_directory
  ]
}

resource "local_file" "promote_to_production_script" {
  filename = "${path.module}/scripts/promote_to_production.sh"
  content  = <<-EOT
    #!/bin/bash

    # Check if staging files exist
    if [ ! -f ${var.staging_dir}/${var.app_name}.jar ]; then
      echo "Error: Staging jar not found"
      exit 1
    fi

    # Backup current production if exists
    if [ -f ${var.production_dir}/${var.app_name}.jar ]; then
      cp ${var.production_dir}/${var.app_name}.jar ${var.production_dir}/${var.app_name}.jar.bak
      echo "Backup created at ${var.production_dir}/${var.app_name}.jar.bak"
    fi

    # Copy from staging to production
    cp ${var.staging_dir}/${var.app_name}.jar ${var.production_dir}/${var.app_name}.jar
    cp ${var.staging_dir}/${var.app_name}.service ${var.production_dir}/${var.app_name}.service

    echo "Application promoted to production at ${var.production_dir}/${var.app_name}.jar"
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }

  depends_on = [
    local_file.production_directory,
    local_file.deploy_script
  ]
}

resource "local_file" "rollback_script" {
  filename = "${path.module}/scripts/rollback.sh"
  content  = <<-EOT
    #!/bin/bash

    # Check if backup exists
    if [ ! -f ${var.production_dir}/${var.app_name}.jar.bak ]; then
      echo "Error: No backup found for rollback"
      exit 1
    fi

    # Restore from backup
    cp ${var.production_dir}/${var.app_name}.jar.bak ${var.production_dir}/${var.app_name}.jar

    echo "Application rolled back to previous version"
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }

  depends_on = [
    local_file.production_directory
  ]
}

# Health check script
resource "local_file" "health_check_script" {
  filename = "${path.module}/scripts/health_check.sh"
  content  = <<-EOT
    #!/bin/bash

    # Define log file
    LOG_FILE="${var.production_dir}/health_checks.log"

    # Timestamp
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # Check if the application is running
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 || echo "ERROR")

    if [ "$RESPONSE" == "200" ]; then
      echo "$TIMESTAMP - Application health check: SUCCESS (HTTP 200)" >> $LOG_FILE
      echo "Health check passed"
      exit 0
    else
      echo "$TIMESTAMP - Application health check: FAILED ($RESPONSE)" >> $LOG_FILE
      echo "Health check failed with response: $RESPONSE"
      exit 1
    fi
  EOT

  provisioner "local-exec" {
    command = "chmod +x ${self.filename}"
  }

  depends_on = [
    local_file.production_directory
  ]
}

# Output configuration
output "production_dir" {
  value = var.production_dir
  description = "Production directory path"
}

output "staging_dir" {
  value = var.staging_dir
  description = "Staging directory path"
}

output "deploy_script" {
  value = local_file.deploy_script.filename
  description = "Path to deployment script"
}

output "promote_script" {
  value = local_file.promote_to_production_script.filename
  description = "Path to promotion script"
}

output "rollback_script" {
  value = local_file.rollback_script.filename
  description = "Path to rollback script"
}

output "health_check_script" {
  value = local_file.health_check_script.filename
  description = "Path to health check script"
}