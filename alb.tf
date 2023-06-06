# ALB 생성
resource "aws_lb" "application_load_balancer" {
  count              = length(aws_vpc.vpc) * 2
  name               = "my-alb-${count.index + 1}"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet[count.index].id]  # 해당 VPC의 public subnet에 연결
  enable_deletion_protection = true

    access_logs {
        bucket  = "my-access-logs-bucket"
        prefix  = "alb-logs/"
        enabled = true
    }

  security_groups = [aws_security_group.alb_security_group[count.index].id]  # ALB의 보안 그룹

  tags = {
    Name = "ALB-${count.index + 1}"
  }
}

# ALB 보안 그룹
resource "aws_security_group" "alb_security_group" {
  count       = length(aws_vpc.vpc)
  name_prefix = "alb-sg-${count.index + 1}"
  description = "ALB Security Group"

  vpc_id = aws_vpc.vpc[count.index].id

  # 인바운드 규칙 정의
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 규칙 정의
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





