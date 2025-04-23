# Local deployment environment configuration

provider "local" {}

# Create staging directory
resource "local_file" "staging_folder" {
  filename = "${path.module}/staging/.keep"
  content  = "This folder is managed by Terraform"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/staging"
  }
}

# Create production directory
resource "local_file" "production_folder" {
  filename = "${path.module}/production/.keep"
  content  = "This folder is managed by Terraform"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/production"
  }
}

# Create logs directory
resource "local_file" "logs_folder" {
  filename = "${path.module}/logs/.keep"
  content  = "This folder is managed by Terraform"

  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/logs"
  }
}