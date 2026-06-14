terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "Terraform-admin"
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
# ================== PRIMARY ==================
resource "aws_db_instance" "postgres" {
  identifier        = var.db_identifier
  engine            = "postgres"
  engine_version    = "16.4"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  deletion_protection    = false

  # REQUIRED for Read Replicas
  backup_retention_period = 1
  backup_window           = "03:00-04:00"

  multi_az = false

  tags = {
    Name        = "${var.db_identifier}-primary"
    Environment = "Testing"
  }
}


# ================== READ REPLICA 1 ==================
resource "aws_db_instance" "replica1" {
  identifier             = "${var.db_identifier}-replica-1"
  instance_class         = var.instance_class
  storage_type           = "gp3"

  replicate_source_db    = aws_db_instance.postgres.identifier   # Important

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.db_identifier}-replica-1"
    Environment = "Testing"
    Role        = "Read-Replica"
  }
}

# ================== READ REPLICA 2 ==================
resource "aws_db_instance" "replica2" {
  identifier             = "${var.db_identifier}-replica-2"
  instance_class         = var.instance_class
  storage_type           = "gp3"

  replicate_source_db    = aws_db_instance.postgres.identifier

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.db_identifier}-replica-2"
    Environment = "Testing"
    Role        = "Read-Replica"
  }
}