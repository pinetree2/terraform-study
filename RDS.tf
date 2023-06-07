resource "aws_db_subnet_group" "subnet_group" {
  count       = length(aws_vpc.vpc)
  name        = "subnet-group-${count.index + 1}"
  description = "Subnet group for RDS in VPC ${count.index + 1}"
  subnet_ids  = [for index, subnet in aws_subnet.private_subnet : subnet[count.index * 2 + index].id]
}

resource "aws_db_instance" "rds" {
  count                = length(aws_db_subnet_group.subnet_group)
  identifier           = "rds-${count.index + 1}"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "song-rds-${count.index + 1}"
  username             = "admin"
  password             = "password"
  db_subnet_group_name = aws_db_subnet_group.subnet_group[count.index].name
  allow_major_version_upgrade = true
}