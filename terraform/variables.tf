variable "postgres_image" {
  description = "PostgreSQL Docker image"
  type        = string
  default     = "postgres:17"
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "devops_fundamentals"
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}