resource "aws_ecs_cluster" "main" {
  name = "sprint-freight-cluster"
}

resource "aws_ecr_repository" "main" {
  name = "sprint-freight-app"
}

resource "aws_ecs_task_definition" "staging" {
  family                   = "sprint-freight-staging"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.iam_ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "sprint-freight-app"
      image = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
      environment = [
        { name = "PORT", value = "3000" },
        { name = "DB_HOST", value = var.rds_endpoint },
        { name = "DB_DATABASE", value = "testdb" },
        { name = "DB_USERNAME", value = "user" },
        { name = "DB_PASSWORD", value = "password" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.cloudwatch_staging_log_group
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "staging"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl --fail http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 3
        retries     = 3
      }
    }
  ])
}

resource "aws_ecs_task_definition" "production" {
  family                   = "sprint-freight-production"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.iam_ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "sprint-freight-app"
      image = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
      environment = [
        { name = "PORT", value = "3000" },
        { name = "NODE_ENV", value = "production" },
        { name = "DB_HOST", value = var.rds_endpoint },
        { name = "DB_DATABASE", value = "testdb" },
        { name = "DB_USERNAME", value = "user" },
        { name = "DB_PASSWORD", value = "password" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.cloudwatch_production_log_group
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "production"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl --fail http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 3
        retries     = 3
      }
    }
  ])
}

resource "aws_ecs_task_definition" "staging_prev" {
  family                   = "sprint-freight-staging-prev"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.iam_ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "sprint-freight-app"
      image = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
      environment = [
        { name = "PORT", value = "3000" },
        { name = "DB_HOST", value = var.rds_endpoint },
        { name = "DB_DATABASE", value = "testdb" },
        { name = "DB_USERNAME", value = "user" },
        { name = "DB_PASSWORD", value = "password" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.cloudwatch_staging_log_group
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "staging"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl --fail http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 3
        retries     = 3
      }
    }
  ])
}

resource "aws_ecs_task_definition" "production_prev" {
  family                   = "sprint-freight-production-prev"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.iam_ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name  = "sprint-freight-app"
      image = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
      environment = [
        { name = "PORT", value = "3000" },
        { name = "NODE_ENV", value = "production" },
        { name = "DB_HOST", value = var.rds_endpoint },
        { name = "DB_DATABASE", value = "testdb" },
        { name = "DB_USERNAME", value = "user" },
        { name = "DB_PASSWORD", value = "password" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.cloudwatch_production_log_group
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "production"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl --fail http://localhost:3000/health || exit 1"]
        interval    = 30
        timeout     = 3
        retries     = 3
      }
    }
  ])
}

resource "aws_ecs_service" "staging" {
  name            = "sprint-freight-staging-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.staging.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "production" {
  name            = "sprint-freight-production-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.production.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.sg_id]
    assign_public_ip = true
  }
}

output "ecr_repo_url" { value = aws_ecr_repository.main.repository_url }
output "ecs_cluster_arn" { value = aws_ecs_cluster.main.arn }

variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "sg_id" {}
variable "iam_ecs_task_execution_role_arn" {}
variable "cloudwatch_staging_log_group" {}
variable "cloudwatch_production_log_group" {}
variable "rds_endpoint" {}
