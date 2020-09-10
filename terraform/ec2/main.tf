provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}


resource "aws_key_pair" "mytest-key" {
  key_name = "my-terraform-key-new1"
  public_key = file("c:/Temp/id_rsa.pub")
}

resource "aws_instance" "my_instance" {
  count = 2
  ami = "ami-0c94855ba95c71c99"
  instance_type = var.instance_type
  key_name = aws_key_pair.mytest-key.id
  vpc_security_group_ids = [var.security_group]
  subnet_id = element(var.subnets, count.index)
  user_data = data.template_file.init.template

  tags = {
    Name = "my-instance-${count.index + 1}"
  }
}

data "template_file" "init" {
#  template = file("${path.module}/userdata.tpl")
  template = file("./userdata.tpl")
}

