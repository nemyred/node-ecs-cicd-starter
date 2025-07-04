resource "aws_cloudwatch_log_group" "staging" {
  name = "/ecs/sprint-freight-staging"
}

resource "aws_cloudwatch_log_group" "production" {
  name = "/ecs/sprint-freight-production"
}

output "staging_log_group" { value = aws_cloudwatch_log_group.staging.name }
output "production_log_group" { value = aws_cloudwatch_log_group.production.name }