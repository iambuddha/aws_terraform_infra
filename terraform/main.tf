provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "ec2" {
  source = "./ec2"
#  my_public_key = "/tmp/id_rsa.pub"
  instance_type = "t2.micro"
  security_group = module.vpc.security1_group
  subnets = module.vpc.subnets
}
