provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-subnet"
  }
}

resource "aws_subnet" "db_second" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "terraform-db-subnet-2"
  }
}

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

resource "aws_security_group" "allow_web" {
  name   = "allow-web"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = "avivhamoy"

  subnet_id = aws_subnet.main.id

  vpc_security_group_ids = [
    aws_security_group.allow_web.id
  ]

  tags = {
    Name = "TerraformServer-avivhamoy"
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

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}
