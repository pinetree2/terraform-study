output "vpc1_id" {
  value = aws_vpc.vpc1.id
}

output "vpc2_id" {
  value = aws_vpc.vpc2.id
}

output "vpc3_id" {
  value = aws_vpc.vpc3.id
}

output "account_id" {
    value = "${data.aws_caller_identity.current.account_id}"
}

