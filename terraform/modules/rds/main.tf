variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "sg_id" {}

resource "aws_db_instance" "main" {
  identifier           = "sprint-freight-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = "user"
  password             = "password"
  db_name              = "testdb"
  vpc_security_group_ids = [var.sg_id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "main" {
  name       = "sprint-freight-db-subnet-group"
  subnet_ids = var.subnet_ids
}

output "endpoint" { value = aws_db_instance.main.endpoint }
