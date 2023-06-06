# Auto Scaling 그룹 정의
resource "aws_autoscaling_group" "autoscaling_group" {
  count                 = 3
  name                  = "autoscaling-group-${count.index + 1}"
  max_size              = 5
  min_size              = 2
  desired_capacity      = 2
  health_check_type     = "ELB"
  launch_configuration = aws_launch_configuration.launch_config[count.index].name

  vpc_zone_identifier = [
    aws_subnet.public_subnet[(count.index * 2)].id,
    aws_subnet.public_subnet[(count.index * 2) + 1].id
  ]
}






