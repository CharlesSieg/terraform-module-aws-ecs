output "image_repo_name" {
  description = "The name of the ECR repository."
  value       = aws_ecr_repository.service.name
}

output "name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_sg" {
  description = ""
  value       = aws_security_group.ecs_sg.id
}

output "service_name" {
  description = "The name of the service."
  value       = aws_ecs_service.ecs_service.name
}
