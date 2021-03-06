#https://github.com/100daysofdevops/21_days_of_aws_using_terraform/
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

module "alb" {
  source = "./alb"
  vpc_id = module.vpc.vpc_id
  instance1_id = module.ec2.instance1_id
  instance2_id = module.ec2.instance2_id
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
}

module "auto_scaling" {
  source = "./auto_scaling"
  vpc_id = module.vpc.vpc_id
  instance_type = "t2.micro"
  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
  alb_target_group_arn = module.alb.alb_target_group_arn
}

module "rds" {
  source = "./rds"
  db_instance = "db.t2.micro"
  rds_subnet1 = module.vpc.privae_subnet1
  rds_subnet2 = module.vpc.privae_subnet2
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./iam"
  username = ["user1", "user2", "user3"]
}