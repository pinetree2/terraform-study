
# DB 서브넷 그룹 생성
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
}

# RDS 생성을 시도...
/*
private subnet 2개를 가진 az 하나의 rds 생성 코드 비스무리하게 ..
여기서 az 는 여러개라서 저런식으로 쓴
*/
resource "aws_db_instance" "rds_az1" {
  count               = length(var.aws_regions) * 2
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb-az1"
  username             = "admin"
  password             = "password"
  publicly_accessible = false
  multi_az             = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_group_name     = aws_db_subnet_group.db_subnet.name
  availability_zone  = element(var.aws_regions, count.index)
}


# 보안 그룹 생성
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

