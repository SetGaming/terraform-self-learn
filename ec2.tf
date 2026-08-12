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
