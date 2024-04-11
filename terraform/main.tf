# -----------------------
# SECURITY GROUPS
# -----------------------

resource "aws_security_group" "alb_sg" {
  name        = "epam-alb-sg"
  description = "Security group for the Application Load Balancer"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "ec2_sg" {
  name        = "epam-ec2-sg"
  description = "Security group for EC2 instances"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------
# INSTANCES
# -----------------------

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_network_interface" "ec2_nic1" {
  subnet_id = aws_subnet.private_subnet1.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "epam_ec2_nic_1"
  }
}

resource "aws_network_interface" "ec2_nic2" {
  subnet_id = aws_subnet.private_subnet2.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "epam_ec2_nic_2"
  }
}


resource "aws_instance" "ec2" {
  count = 2
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = count.index == 0 ? aws_network_interface.ec2_nic1.id : aws_network_interface.ec2_nic2.id
    device_index         = 0
  }

  user_data = file("./http_install.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "epam_ec2_instance_${count.index + 1}"
  }
}

# -----------------------
# LOAD BALANCER
# -----------------------

resource "aws_lb" "alb" {
  name               = "epam-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "epam-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  count = 2
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.ec2[count.index].id
  port             = 80
}