# Configure the AWS Provider
provider "aws" {
  region = var.aws_regions[0]
}

# 리전별 VPC 생성
resource "aws_vpc" "example_vpc" {
  count             = length(var.aws_regions)
  cidr_block        = "10.0.${count.index}.0/16"
  instance_tenancy  = "default"
  region            = var.aws_regions[count.index]

  tags = {
    Name = "Example-VPC-${count.index}"
  }
}

#WAF 구현
resource "aws_wafv2_ip_set" "example" {
  name               = "test-waf"
  description        = "Example IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["1.2.3.4/32", "5.6.7.8/32"]

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }
}

#public subnet 생성
resource "aws_subnet" "example_public_subnet" {
  count             = length(var.aws_regions) * 2
  vpc_id            = aws_vpc.example_vpc[count.index / 2].id
  cidr_block        = var.public_subnet_cidrs[var.aws_regions[count.index / 2]][count.index % 2]
  availability_zone = var.availability_zones[var.aws_regions[count.index / 2]][count.index % 2]

  tags = {
    Name = "example-public-subnet-${var.aws_regions[count.index / 2]}-${count.index % 2}"
  }
}

#private subnet 생성 
resource "aws_subnet" "example_private_subnet" {
  count             = length(var.aws_regions) * 2
  vpc_id            = aws_vpc.example_vpc[count.index / 2].id
  cidr_block        = var.private_subnet_cidrs[var.aws_regions[count.index / 2]][count.index % 2]
  availability_zone = var.availability_zones[var.aws_regions[count.index / 2]][count.index % 2]

  tags = {
    Name = "example-private-subnet-${var.aws_regions[count.index / 2]}-${count.index % 2}"
  }
}

#ALB 생성(중)
resource "aws_lb" "example_lb" {
  count           = length(var.aws_regions) * length(var.availability_zones[var.aws_regions[count.index / 2]])
  name            = "example-lb-${count.index}"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.example_sg.id]
  subnets         = [
    aws_subnet.example_public_subnet[count.index].id
  ]

  tags = {
    Name = "example-lb-${count.index}"
  }
}

resource "aws_wafv2_web_acl" "example_waf" {
  count           = length(var.aws_regions) * length(var.availability_zones[var.aws_regions[count.index / 2]])
  name            = "example-waf-${count.index}"
  scope           = "REGIONAL"
  rules           = []
  default_action {
    block {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example-waf-metrics-${count.index}"
    sampled_requests_enabled  = true
  }

  depends_on = [
    aws_lb.example_lb
  ]
}

resource "aws_security_group" "example_sg" {
  count       = length(var.aws_regions) * length(var.availability_zones[var.aws_regions[count.index / 2]])
  vpc_id      = aws_vpc.example_vpc[count.index / 2].id
  name        = "example-security-group-${count.index}"
  description = "Example Security Group"

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
    Name = "example-security-group-${count.index}"
  }
}

resource "aws_ec2_transit_gateway" "example_tgw" {
  count           = length(var.aws_regions)
  transit_gateway_id     = "example-tgw-${count.index}"
  description     = "Example Transit Gateway"

  tags = {
    Name = "example-tgw-${count.index}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example_tgw_attachment" {
  count           = length(var.aws_regions)
  transit_gateway_id     = aws_ec2_transit_gateway.example_tgw[count.index].id
  vpc_id          = aws_vpc.example_vpc[count.index].id
  subnet_ids      = [
    aws_subnet.example_private_subnet[count.index * 2].id,
    aws_subnet.example_private_subnet[count.index * 2 + 1].id
  ]

  tags = {
    Name = "example-tgw-attachment-${count.index}"
  }
}