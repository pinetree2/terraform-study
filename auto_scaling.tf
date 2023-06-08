/*
# Auto Scaling 그룹 정의
resource "aws_autoscaling_group" "autoscaling_group" {
  count                 = 3
  name                  = "autoscaling-group-${count.index + 1}"
  max_size              = 5
  min_size              = 2
  desired_capacity      = 2
   ## target그룹 연결
  target_group_arns = [aws_lb_target_group.target_group[count.index].arn]
  launch_configuration = aws_launch_configuration.launch_configuration.name

  health_check_type     = "ELB"
  vpc_zone_identifier = [
    aws_subnet.public_subnet[(count.index * 2)].id,
    aws_subnet.public_subnet[(count.index * 2) + 1].id
  ]
}


# Launch Configuration 정의
resource "aws_launch_configuration" "launch_configuration" {
  name                 = "my-launch-configuration"
  image_id             = "ami-xxxxxxxx"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.my_security_group.id]
  # 기타 구성 옵션 설정
}
*/