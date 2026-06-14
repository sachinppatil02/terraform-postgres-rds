output "rds_endpoint" {
  description = "RDS Endpoint to connect with psql"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "RDS Port"
  value       = aws_db_instance.postgres.port
}

output "rds_username" {
  description = "Master Username"
  value       = aws_db_instance.postgres.username
}

output "connection_command" {
  description = "Example psql connection command"
  value       = "psql -h ${aws_db_instance.postgres.endpoint} -p 5432 -U ${aws_db_instance.postgres.username} -d ${var.db_name}"
}

output "security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "replica1_endpoint" {
  value = aws_db_instance.replica1.endpoint
}

output "replica2_endpoint" {
  value = aws_db_instance.replica2.endpoint
}

output "all_endpoints" {
  value = {
    primary  = aws_db_instance.postgres.endpoint
    replica1 = aws_db_instance.replica1.endpoint
    replica2 = aws_db_instance.replica2.endpoint
  }
}