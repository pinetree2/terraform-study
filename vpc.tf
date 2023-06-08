

# VPC 리소스 정의
resource "aws_vpc" "vpc" {
  count = length(aws_vpc.vpc) * 2
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, count.index)

  tags = {
    Name = "song-vpc${count.index + 1}"
  }
}



# 가용 영역에 따라 public 서브넷 생성
resource "aws_subnet" "public_subnet" {
  count                   = length(aws_vpc.vpc) * 2
  vpc_id                 = aws_vpc.vpc[count.index / 2].id
  cidr_block             = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index % length(var.azs))


  tags = {
    Name = "song-public_subnet${count.index + 1}"
  }
}

# 가용 영역에 따라 private 서브넷 생성
resource "aws_subnet" "private_subnet" {
  count                   = length(aws_vpc.vpc) * 2
  vpc_id                 = aws_vpc.vpc[count.index / 2].id
  cidr_block             = var.private_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index % length(var.azs))

  map_public_ip_on_launch = false #퍼블릭 IP 부여를 하지 않습니다.
  tags = {
    Name = "song-private_subnet${count.index + 1}"
  }
}


# Public 서브넷에 대한 라우팅 테이블 생성
resource "aws_route_table" "public_route_table" {
  count                = length(aws_vpc.vpc) * 2
  vpc_id               = aws_vpc.vpc[count.index / 2].id

  tags = {
    Name = "PublicRouteTable${count.index + 1}"
  }
}

# Private 서브넷에 대한 라우팅 테이블 생성
resource "aws_route_table" "private_route_table" {
  count                = length(aws_vpc.vpc) * 2
  vpc_id               = aws_vpc.vpc[count.index / 2].id

  tags = {
    Name = "PrivateRouteTable${count.index + 1}"
  }
}

# Public 서브넷에 대한 라우팅 테이블 연결 생성
resource "aws_route_table_association" "public_route_table_association" {
  count            = length(aws_vpc.vpc) * 2
  subnet_id        = aws_subnet.public_subnet[count.index].id
  route_table_id   = aws_route_table.public_route_table[count.index].id
}

# Private 서브넷에 대한 라우팅 테이블 연결 생성
resource "aws_route_table_association" "private_route_table_association" {
  count            = length(aws_vpc.vpc) * 2
  subnet_id        = aws_subnet.private_subnet[count.index].id
  route_table_id   = aws_route_table.private_route_table[count.index].id
}


#보안그룹
resource "aws_security_group" "song-sg" {
  count = length(aws_vpc.vpc) * 2

  name        = "sg_${count.index + 1}"
  description = "Security Group ${count.index + 1}"
  vpc_id      = aws_vpc.vpc[count.index / 2].id

 # 인바운드 규칙 정의
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 아웃바운드 규칙 정의
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "song-sg_${count.index + 1}"
  }
}


#ec2 생성
resource "aws_instance" "ec2" {
  count         = length(aws_vpc.vpc) * 2
  ami = var.AMIS 
  instance_type = "t2.micro"
  #key_name                    = "${aws_key_pair.test-tgw-keypair.key_name}"
  vpc_security_group_ids = [aws_security_group.song-sg[count.index].id]
  availability_zone = element(var.azs, count.index % length(var.azs))
  subnet_id     = aws_subnet.public_subnet[count.index].id

tags = {
    Name = "song-ec2_${count.index + 1}"
  }
}
