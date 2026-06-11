variable "region" {
  default = "us-east-1"
}

variable "db_name" {
  default = "mydb"
}

variable "db_username" {
  default = "postgresadmin"
}

variable "db_password" {
  description = "The password for the PostgreSQL DB"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  default = 20
}
