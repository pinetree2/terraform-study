
# Auto Scaling 그룹 정의
resource "aws_autoscaling_group" "autoscaling_group" {
  count                 = 3
  name                  = "autoscaling-group-${count.index + 1}"
  launch_configuration = "${aws_launch_configuration.launch_configuration[count.index].id}"
  min_size             = "${var.autoscaling_group_min_size}"
  max_size             = "${var.autoscaling_group_max_size}"

   ## target그룹 연결
  target_group_arns = [aws_lb_target_group.target_group[count.index].arn]
  health_check_type     = "ELB"
  vpc_zone_identifier = [
    aws_subnet.public_subnet[(count.index * 2)].id,
    aws_subnet.public_subnet[(count.index * 2) + 1].id
  ]
}

resource "aws_security_group" "asg_sg" {
   count                   = length(aws_vpc.vpc) * 2
  name        = "ASG_Allow_Traffic"
  description = "Allow all inbound traffic for asg"
  vpc_id      = aws_vpc.vpc[count.index % length(aws_vpc.vpc)].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-asg-security-group"
  }
}

# Launch Configuration 정의
resource "aws_launch_configuration" "launch_configuration" {
  count                = length(aws_vpc.vpc) * 2
  name_prefix          = "my-launch-configuration"
  image_id             = "ami-091a822378848a5bf"
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.asg_sg[count.index].id}"]
  # 기타 구성 옵션 설정
}
