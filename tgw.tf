#Create Transit Gateway
resource "aws_ec2_transit_gateway" "test-tgw" {
  description = "Transit Gateway"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = {
      Name = "song-tgw"
  }
}

# Transit Gateway VPC Attachment 생성
resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_attachment" {
  count          = length(aws_vpc.vpc)
  subnet_ids     = [aws_subnet.public_subnet[count.index].id]  # Transit Gateway 연결에 사용할 서브넷 선택
  transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  vpc_id         = aws_vpc.vpc[count.index].id
  dns_support    = true
  ipv6_support   = false
}

# Transit Gateway VPC Attachment에 대한 라우팅 테이블 연결 생성
resource "aws_route_table_association" "transit_gateway_attachment_association" {
  count          = length(aws_vpc.vpc)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}


# Transit Gateway VPC Attachment의 라우팅 테이블에 대한 라우트 설정
resource "aws_route" "transit_gateway_attachment_route" {
  count                  = length(aws_vpc.vpc)
  route_table_id         = aws_route_table.public_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"  # 대상 CIDR 블록 설정 (필요에 따라 수정) 인터넷으로 모든 트래픽을 전달하려는 경우 0.0.0.0/0을 사용
  transit_gateway_id     = aws_ec2_transit_gateway.test-tgw.id
}