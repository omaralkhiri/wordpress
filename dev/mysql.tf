# This method is used to obtain data from terraform.tfstate
data "terraform_remote_state" "public_subnets_ids" {
  backend = "s3"
  config = {
    bucket = "terraformstate"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

module "mysql" {
  source              = "../modules/mysql"
  db_name             = "wordpress"
  username            = "mysql"
  password            = "lKpyyZfY7wmY7Faz0imzFFF"
  instance_type       = "db.t3.micro"
  identifier          = "wordpress"
  vpc_cidr            = var.vpc_cidr
  skip_final_snapshot = false
  target_env          = var.target_env
  database_subnets    = data.terraform_remote_state.public_subnets_ids.outputs.public_subnets_ids
  vpc_id              = data.terraform_remote_state.public_subnets_ids.outputs.vpc_id
  depends_on = [ module.network ]
}