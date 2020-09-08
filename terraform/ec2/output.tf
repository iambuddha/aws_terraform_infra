output "instance1_id" {
  value = element(aws_instance.my_instance.*.id, 1)
}

output "instance2_id" {
  value = element(aws_instance.my_instance.*.id, 2)
}
