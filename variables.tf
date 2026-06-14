variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "RDS Instance Identifier"
  type        = string
  default     = "test-postgres-rds"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "testdb"
}

variable "db_username" {
  description = "Master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "allowed_ip" {
  description = "Your public IP address to allow connection (use 0.0.0.0/0 for anywhere - not recommended)"
  type        = string
  default     = "0.0.0.0/0" # Change this to your IP for better security
}

variable "instance_class" {
  description = "RDS Instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage in GB"
  type        = number
  default     = 20
}