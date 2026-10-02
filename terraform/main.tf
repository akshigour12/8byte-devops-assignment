module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  app_port = 5000
}
module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name
  environment  = var.environment

  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security_groups.app_security_group_id

  instance_type = "t3.micro"
  ami_id        = ""
}
module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids   = module.vpc.private_subnet_ids
  db_security_group_id = module.security_groups.db_security_group_id

  db_name           = "appdb"
  db_username       = "appadmin"
  db_instance_class = "db.t3.micro"
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id

  target_instance_id = module.ec2.instance_id

  app_port = 5000
}
