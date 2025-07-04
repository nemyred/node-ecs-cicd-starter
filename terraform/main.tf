provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "rds" {
  source     = "./modules/rds"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
  sg_id      = module.vpc.sg_id
}

module "ecs" {
  source                         = "./modules/ecs"
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.subnet_ids
  sg_id                          = module.vpc.sg_id
  rds_endpoint                   = module.rds.endpoint
  iam_ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  cloudwatch_staging_log_group   = module.cloudwatch.staging_log_group
  cloudwatch_production_log_group = module.cloudwatch.production_log_group
}

output "ecr_repository_url" {
  value = module.ecs.ecr_repo_url
}
