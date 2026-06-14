terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

}

################################
# VPC
################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

################################
# PUBLIC SUBNETS
################################

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-1"
    Type = "Public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-2"
    Type = "Public"
  }
}

################################
# PRIVATE SUBNETS
################################

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Subnet-1"
    Type = "Private"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-Subnet-2"
    Type = "Private"
  }
}

################################
# INTERNET GATEWAY
################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

################################
# PUBLIC ROUTE TABLE
################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-RouteTable"
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

################################
# PRIVATE ROUTE TABLE
################################

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private-RouteTable"
  }
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

################################
# SECURITY GROUP
################################

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "PostgreSQL"

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "103.197.74.18/32"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-rds-sg"
  }
}

################################
# DB SUBNET GROUP
################################

resource "aws_db_subnet_group" "postgres" {
  name = "postgres-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "postgres-subnet-group"
  }
}

################################
# POSTGRESQL RDS
################################

resource "aws_db_instance" "postgres" {

  identifier = "sachinpgdb"

  engine         = "postgres"
  engine_version = "16.3"

  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  publicly_accessible = true

  skip_final_snapshot = true

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  tags = {
    Name        = "PostgreSQL-RDS"
    Environment = "Dev"
  }
}