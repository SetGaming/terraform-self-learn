resource "aws_db_subnet_group" "main" {
  name = "terraform-db-subnet-group"

  subnet_ids = [
    aws_subnet.main.id,
    aws_subnet.db_second.id
  ]

  tags = {
    Name = "terraform-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name   = "terraform-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    security_groups = [
      aws_security_group.allow_web.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-rds-sg"
  }
}

resource "aws_db_instance" "terraform_db" {
  identifier = "terraform-db-avivhamoy"

  allocated_storage = 20
  storage_type      = "gp3"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  db_name  = "terraformdb"
  username = "adminuser"
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot = true

  tags = {
    Name = "TerraformDB-avivhamoy"
  }
}
