provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "microservices_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.app.name
  min_size             = 2
  max_size             = 5
  vpc_zone_identifier  = [aws_subnet.public.id]
}

resource "aws_launch_configuration" "app" {
  image_id      = "ami-12345678"
  instance_type = "t2.micro"
  user_data     = file("${path.module}/userdata.sh")

  security_groups = [aws_security_group.microservices_sg.id]
}
