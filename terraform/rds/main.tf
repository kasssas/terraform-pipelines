variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "eks_node_sg_id" {}

resource "aws_db_subnet_group" "rds" {
  name       = "backend-db-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "backend-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-backend-sg"
  description = "Allow inbound traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "backend" {
  identifier             = "backend-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t4g.micro"
  db_name                = "backend"
  username               = "appuser"
  password               = "apppass"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

output "endpoint" {
  value = aws_db_instance.backend.endpoint
}
