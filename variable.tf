
# region 변수
variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "autoscaling_group_min_size" {
  type = number
  default = 2
}
variable "autoscaling_group_max_size" {
  type = number
  default = 3
}


#AZ
variable "azs" {
  type    = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

# public subnet 변수 
variable "public_subnet_cidrs" {
  type = list(string)
  default =["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24","10.0.5.0/24"]

}

#private subnet 변수 
variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.1.10.0/24", "10.1.11.0/24","10.1.12.0/24","10.1.13.0/24","10.1.14.0/24","10.1.15.0/24"]
  
}

#vpc 변수 
variable "vpc_cidr_blocks"{
  type = list(string)
  default = ["10.0.0.0/16","10.1.0.0/16","10.2.0.0/16"]
}

variable "AMIS" {
  type = string
  default = "ami-0da26429dcc7b22b4"
}
