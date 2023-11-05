resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { "Name" = "db-sg" })
}
  
resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_unicode_ci"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8_unicode_ci"
  }

  tags = merge(var.tags, { "Name" = "db-pg" })
}

resource "aws_security_group" "db" {
  name        = "db-secg"
  description = "Allow 3306 port"
  vpc_id      = var.vpc_id

 tags = merge(var.tags, { "Name" = "db-secg" })
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.db.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "-1"
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_3306" {
  security_group_id = aws_security_group.db.id

  cidr_ipv4   = var.vpc_cidr_block
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_3306_2" {
  security_group_id = aws_security_group.db.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_secretsmanager_secret" "db" {
  name = "db/master-creds"
  recovery_window_in_days = 0
}

resource "random_password" "db_password" {
  length           = 16
  special          = false
  
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    "host" = aws_db_instance.main.address,
    "username" = var.db_username,
    "password" = random_password.db_password.result,
    "dbname" = var.db_name,
    "port" = 3306
  })
}

resource "aws_db_instance" "main" {
  identifier = "db-demo"
  allocated_storage    = 10
  db_name              = var.db_name
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = random_password.db_password.result
  parameter_group_name = aws_db_parameter_group.default.name
  skip_final_snapshot  = true
  publicly_accessible = true
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.default.name
}