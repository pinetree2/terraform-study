
# 보안 그룹 리소스 정의
resource "aws_security_group" "alb_security_group" {
  count       = 3
  name        = "alb-security-group-${count.index + 1}"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc[count.index / 2].id

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

  tags = {
    Name = "alb-security-group-${count.index + 1}"
  }
}


# ALB 리소스 정의
resource "aws_lb" "alb" {
  count             = 3
  name              = "alb-${count.index + 1}"
  load_balancer_type = "application"
  security_groups   = [aws_security_group.alb_security_group[count.index].id]
  subnets           = [
    aws_subnet.public_subnet[(count.index * 2)].id,
    aws_subnet.public_subnet[(count.index * 2) + 1].id
  ]

  tags = {
    Name = "song-alb-${count.index + 1}"
  }
}

# ALB 타겟 그룹 리소스 정의
resource "aws_lb_target_group" "target_group" {
  count     = 3
  name      = "target-group-${count.index + 1}"
  port      = 80
  protocol  = "HTTP"
  vpc_id    = aws_vpc.vpc[count.index / 2].id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# ALB 리스너 리소스 정의
resource "aws_lb_listener" "listener" {
  count              = 3
  load_balancer_arn  = aws_lb.alb[count.index].arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
    type             = "forward"
  }
}

