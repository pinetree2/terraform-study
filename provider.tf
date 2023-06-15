# Configure the AWS Provider

variable "aws_access_key" {}
variable "aws_secret_key" {}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27.0"
    }
  }
}


provider "aws" {
  alias  = "region1"
  region = var.region[0]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias  = "region2"
  region = var.region[1]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias  = "region3"
  region = var.region[2]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias = "tgw-region"
  region = var.region[3]
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}