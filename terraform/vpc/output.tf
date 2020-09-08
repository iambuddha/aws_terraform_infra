output "aws_vpc_id" {
  value = aws_vpc.main.id
}

output "security1_group" {
  value = aws_security_group.test_sg.id
}

output "subnets" {
  value = aws_subnet.public_subnet.*.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet1" {
  value = element(aws_subnet.public_subnet.*.id, 1)
}

output "subnet2" {
  value = element(aws_subnet.public_subnet.*.id, 2)
}

output "privae_subnet1" {
  value = element(aws_subnet.private_subnet.*.id, 1)
}

output "privae_subnet2" {
  value = element(aws_subnet.private_subnet.*.id, 2)
}