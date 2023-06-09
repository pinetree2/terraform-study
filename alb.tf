

resource "aws_security_group" "elb_sg" {
  count       = 3
  name        = "alb-security-group-${count.index + 1}"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.vpc[count.index % length(aws_vpc.vpc)].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
  security_groups   = [aws_security_group.elb_sg[count.index % length(aws_security_group.elb_sg)].id]
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
  vpc_id    = aws_vpc.vpc[count.index % length(aws_vpc.vpc)].id
  target_type = "instance"

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

data "aws_instances" "ec2_list" {
  instance_state_names = ["running"]
}

resource "aws_lb_target_group_attachment" "targetgroupAttach" {
  count = "${length(data.aws_instances.ec2_list.ids)}"
  target_group_arn = aws_lb_target_group.target_group[count.index % length(aws_lb_target_group.target_group)].arn
  target_id        = "${data.aws_instances.ec2_list.ids[count.index]}"
  port             = 80
}

# ALB 리스너 리소스 정의
resource "aws_lb_listener" "listener" {
  count              = 3
  load_balancer_arn  = aws_lb.alb[count.index].arn
  port               = 80
  protocol           = "HTTP"

  default_action {
    type             = "forward"
    forward{
    target_group{
      arn = aws_lb_target_group.target_group[count.index % length(aws_lb_target_group.target_group)].arn
      } 

    }
    
  }
}

/*
data "aws_subnet_ids" "GetSubnet_Ids" {
  vpc_id = data.aws_vpc.GetVPC.id
  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}
*/