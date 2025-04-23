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

variable "staging_port" {
  description = "Port for staging environment"
  type        = number
  default     = 8081
}

variable "production_port" {
  description = "Port for production environment"
  type        = number
  default     = 8080
}