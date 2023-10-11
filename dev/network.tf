module "network" {
  source               = "../modules/network"
  target_env           = var.target_env
  vpc_cidr             = var.vpc_cidr
  pub_sub1_cidr_block  = var.pub_sub1_cidr_block
  pub_sub2_cidr_block  = var.pub_sub2_cidr_block
  priv_sub1_cidr_block = var.priv_sub1_cidr_block
  priv_sub2_cidr_block = var.priv_sub2_cidr_block
  availability_zone_1  = var.availability_zone_1
  availability_zone_2  = var.availability_zone_2
}