module "vpc" {
  source = "./modules/vpc"

  vpc_name        = var.vpc_name
  cidr_block      = var.vpc_cidr
  cluster_name    = var.cluster_name
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}
