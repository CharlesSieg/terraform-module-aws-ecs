variable "app_name" {
  description = "application name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account number in which the infrastructure will be provisioned."
  type        = string
}

variable "aws_region" {
  description = "The AWS region in which the infrastructure will be provisioned."
  type        = string
}

variable "container_name" {
  description = "The name of the container created in the ECS service."
  type        = string
}

variable "container_port" {
  description = "The port on which the container listens."
  type        = string
}

variable "cpu" {
  description = ""
  type        = string
}

variable "dns_server" {
  description = "IP address of the primary DNS server used by ECS instances."
  type        = string
}

variable "ebs_optimized" {
  type = bool
}

variable "ecr_name" {
  description = "Name of the repository in ECR."
  type        = string
}

variable "ecs_ami_id" {
  description = "The regional ID of the ECS-optimized AMI for cluster instances."
  type        = string
}

variable "email_queue_url" {
  description = "The URL of the SQS queue intended for email use."
  type        = string
}

variable "endpoint" {
  description = "The DNS address of the RDS instance"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ingress_cidr_block" {
  description = "The CIDR block on which to allow ingress."
  type        = string
}

variable "instance_count" {
  description = "Number of ecs nodes to launch"
  type        = number
}

variable "instance_profile_id" {
  description = "ID of the IAM instance profile used for ECS."
  type        = string
}

variable "instance_type" {
  description = "Default instance type for ecs nodes"
  type        = string
}

variable "max_instance_count" {
  description = "Maximum number of ECS nodes that can be launched."
  type        = number
}

variable "memory" {
  description = ""
  type        = string
}

variable "min_instance_count" {
  description = "Minimum number of ECS nodes that will be launched."
  type        = number
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

variable "reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas."
  type        = string
}

variable "redis_host" {
  description = "The address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
  type        = string
}

variable "service_name" {
  description = "Name of the ECS cluster service to be created."
  type        = string
}

variable "slack_queue_url" {
  description = "The URL of the SQS queue intended for Slack use."
  type        = string
}

variable "task_definition_name" {
  description = ""
  type        = string
}

variable "task_execution_role_arn" {
  description = "The ARN of the ecs_task_execution_role."
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the ecs_task_role."
  type        = string
}

variable "tg_arns" {
  description = "ARNs for the target groups that will drive instance provisioning in the Auto Scaling Group."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}
