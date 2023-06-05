
# region 변수
variable "aws_regions" {
  type    = list(string)
  default = [ "ap-northeast-2","ap-northeast-1", "us-east-1"]
}

#AZ 
variable "availability_zones" {
  type = map(list(string))
  default = {
    "us-west-2"      = ["us-west-2a", "us-west-2b"]
    "ap-northeast-1" = ["ap-northeast-1a", "ap-northeast-1c"]
    "us-east-1"      = ["us-east-1a", "us-east-1b"]
  }
}

# public subnet 변수 
variable "public_subnet_cidrs" {
  type = map(list(string))
  default = {

    "ap-northeast-2" = ["10.0.0.0/24","10.0.1.0/24"]
    "ap-northeast-1" = ["10.1.0.0/24", "10.1.1.0/24"]
    "us-east-1"      = ["10.2.0.0/24", "10.2.1.0/24"]
  }

}

#private subnet 변수 
variable "private_subnet_cidrs" {
  type = map(list(string))
  default = {
    "us-west-2"      = ["10.0.10.0/24", "10.0.11.0/24"]
    "ap-northeast-1" = ["10.1.10.0/24", "10.1.11.0/24"]
    "us-east-1"      = ["10.2.10.0/24", "10.2.11.0/24"]
  }
}

#vpc 변수
/*
variable "vpc_cidr_blocks"{
  type = list(string)
  default = ["10.0.0.0/16","10.1.0.0/16","10.2.0.0/16"]
}

#vpc id 변수
variable "vpc_id"{
  default = "vpc-051f05f5b2bf0c20a"
}

variable "subnet_id"{
  default = ["subnet-083b75299435748a3","subnet-0238ee1267f3c3ff3"]
}

*/

variable"AMIS"{
	type = "map"
	default = {
		us-east-1 = "ami-~"
		us-west-2 = "ami-~"
		eu-west-1 = "ami-~"
	}
}	