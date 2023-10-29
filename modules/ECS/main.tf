resource "aws_kms_key" "kms_key" {
  deletion_window_in_days = 7
}

# This resource use to view log in cloudwatch
resource "aws_cloudwatch_log_group" "ecs_cluster_cloudwatch" {
  name = "ecs_cluster_cloudwatch"
}

# Runtime and management environment for container applications
# Timing uses KMS to protect data being processed or stored in containers
resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.kms_key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster_cloudwatch.name
      }
    }
  }
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = "your-secret-name"  
}

# Define container configuration
resource "aws_ecs_task_definition" "wordpress_task" {
  family                   = "wordpress"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = <<EOF
[
  {
    "name": "${var.container_name}",
    "image": "${var.image}", 
    "portMappings": [
      {
        "containerPort": ${var.containerport},
        "hostPort": ${var.hostport}
      }
    ],
    "environment": [
      {
        "name": "WORDPRESS_DB_HOST",
        "value": ${var.mysql_url}
      },
      {
        "name": "WORDPRESS_DB_USER",
        "value": "${data.aws_secretsmanager_secret_version.rds_credentials.secret["username"]}"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD",
        "value": "${data.aws_secretsmanager_secret_version.rds_credentials.secret["password"]}"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "value": "${var.dbname}"
      }
    ]
  }
]
EOF
}

# facilitates the management of service containers on ECS (FARGATE It is fully managed by AWS)
resource "aws_ecs_service" "wordpress_service" {
  name            = "wordpress-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.wordpress_task.arn
  launch_type     = "FARGATE"
  desired_count   = 3

  network_configuration {
    security_groups = [aws_security_group.ecs_sg.id]
    subnets         = [var.subnet]
  }

  load_balancer {
    target_group_arn = var.target_group_arn 
    container_name   = "wordpress-service"
    container_port   = 80
  }
}