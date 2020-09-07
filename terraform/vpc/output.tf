output "aws_vpv_id" {
  value = aws_vpc.main.id
}

output "security1_group" {
  value = aws_security_group.test_sg.id
}

output "subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}