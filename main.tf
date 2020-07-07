###################################################################
# ECS
###################################################################

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-${var.app_name}-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${aws_ecs_cluster.ecs_cluster.name}"
}

resource "aws_ecr_repository" "service" {
  name = var.ecr_name
}

resource "aws_ecs_task_definition" "main" {
  cpu                      = var.cpu
  depends_on               = ["aws_ecs_cluster.ecs_cluster"]
  execution_role_arn       = var.task_execution_role_arn
  family                   = var.task_definition_name
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  task_role_arn            = var.task_role_arn

  container_definitions = <<DEFINITION
[
{
    "command": [],
    "cpu": ${var.cpu},
    "entryPoint": null,
    "environment": [{
        "name": "NODE_ENV",
        "value": "${var.environment}"
    },{
        "name": "dbHost",
        "value": "${var.endpoint}"
    },{
        "name": "dbHostReader",
        "value": "${var.reader_endpoint}"
    },{
        "name": "redisHost",
        "value": "${var.redis_host}"
    },{
        "name": "emailMessageQueueUrl",
        "value": "${var.email_queue_url}"
    },{
        "name": "slackMessageQueueUrl",
        "value": "${var.slack_queue_url}"
    }],
    "essential": true,
    "dnsServers": [
        "${var.dns_server}",
        "8.8.8.8"
    ],
    "image": "${aws_ecr_repository.service.repository_url}:latest",
    "linuxParameters": null,
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${aws_ecs_cluster.ecs_cluster.name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "memory": ${var.memory},
    "name": "${var.container_name}",
    "portMappings": [{
        "containerPort": ${var.container_port},
        "hostPort": ${var.container_port}
    }],
    "workingDirectory": "/usr/src/app"
}
]
DEFINITION
}

resource "aws_ecs_service" "ecs_service" {
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  depends_on                         = ["aws_ecs_task_definition.main"]
  deployment_minimum_healthy_percent = "50"
  desired_count                      = var.instance_count
  name                               = "${var.environment}-${var.app_name}-svc"
  task_definition                    = "${aws_ecs_task_definition.main.family}:${aws_ecs_task_definition.main.revision}"
}

###################################################################
# SECURITY GROUPS
###################################################################

#
# Create the single security group to manage traffic to the instances in the cluster.
#
resource "aws_security_group" "ecs_sg" {
  name   = "${var.environment}-${var.app_name}-ecs-sg"
  vpc_id = var.vpc_id

  tags = {
    Application = "${var.app_name}"
    Billing     = "${var.environment}"
    Environment = "${var.environment}"
    Name        = "${var.environment}-${var.app_name}-ecs-sg"
    Terraform   = "true"
  }
}

#
# Create all of the rules for this security group.
#
resource "aws_security_group_rule" "ecs_egress_all" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_sg.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "ecs_ingress" {
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.ecs_sg.id
  self              = true
  type              = "ingress"
}

resource "aws_security_group_rule" "ecs_ingress_ssh" {
  cidr_blocks       = ["${var.ingress_cidr_block}"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "ecs_ingress_3000" {
  cidr_blocks       = ["${var.ingress_cidr_block}"]
  from_port         = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  to_port           = 3000
  type              = "ingress"
}

###################################################################
# LAUNCH CONFIGURATION
###################################################################

resource "aws_launch_configuration" "instance" {
  associate_public_ip_address = true
  ebs_optimized               = true
  iam_instance_profile        = var.instance_profile_id
  image_id                    = var.ecs_ami_id
  instance_type               = var.instance_type
  name_prefix                 = "${var.environment}-${var.app_name}-"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "30"
    volume_type           = "standard"
  }

  security_groups = [aws_security_group.ecs_sg.id]

  user_data = <<EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
              EOF
}

###################################################################
# AUTO SCALING GROUP
###################################################################

resource "aws_autoscaling_group" "asg" {
  default_cooldown          = "1"
  depends_on                = ["aws_launch_configuration.instance"]
  health_check_grace_period = 600
  health_check_type         = "EC2" //ELB"
  launch_configuration      = aws_launch_configuration.instance.id
  name                      = "${var.environment}-${var.app_name}-asg"
  target_group_arns         = var.tg_arns
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = var.private_subnets
  wait_for_capacity_timeout = "0"

  desired_capacity = var.instance_count
  max_size         = var.max_instance_count
  min_size         = var.min_instance_count

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Application"
    value               = var.app_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Billing"
    value               = "${var.environment}-${var.app_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${var.app_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
}
