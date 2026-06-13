output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_1" {
  value = aws_subnet.public_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_2.id
}

output "private_subnet_1" {
  value = aws_subnet.private_1.id
}

output "private_subnet_2" {
  value = aws_subnet.private_2.id
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_identifier" {
  value = aws_db_instance.postgres.id
}