terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50"
    }
  }
}

provider "aws" {
  region = var.region
  profile= "Terraform-admin"
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.db_identifier}-sg"
  description = "Allow PostgreSQL inbound traffic"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "Allow Postgres from allowed IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_identifier}-sg"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier             = var.db_identifier
  engine                 = "postgres"
  engine_version         = "16.4"           # or "17" if available in your region
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false

  # Performance & backup settings for test environment
  backup_retention_period = 0
  multi_az                = false

  tags = {
    Name        = var.db_identifier
    Environment = "Testing"
  }
}