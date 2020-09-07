provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "my-new-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-public-route"
  }
}

resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "may-private-route-table"
  }
}

#Public subnet

resource "aws_subnet" "public_subnet" {
  count = 2
  cidr_block = var.public_cidrs[count.index]
  vpc_id = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "my-public-subnet.${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  cidr_block = var.private_cidrs[count.index]
  vpc_id = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "my-private-subnet.${count.index + 1}"
  }
}

#Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count = 2
  route_table_id = aws_route_table.public_route.id
#  subnet_id = [aws_subnet.public_subnet.*.id[count.index]]
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on = [aws_route_table.public_route, aws_subnet.public_subnet]
}

resource "aws_route_table_association" "private_subnet_assoc" {
  count = 2
  route_table_id = aws_route_table.public_route.id
#  subnet_id = [aws_subnet.private_subnet.*.id[count.index]]
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  depends_on = [aws_default_route_table.private_route, aws_subnet.private_subnet]
}

#security group creation
resource "aws_security_group" "test_sg" {
  name = "my-test-sg"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.test_sg.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "tcp_inbound_access" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.test_sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.test_sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}