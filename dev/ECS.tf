# This method is used to obtain data from terraform.tfstate
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "DevWordpress"
    key    = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "ECS_RDS" {
  backend = "s3"
  config = {
    bucket = "DevWordpress"
    key    = "Ecs/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "wordpress" {
  source           = "../modules/ECS"
  container_name   = "wordpress"
  image            = "wordpress:latest"
  containerport    = 80
  hostport         = 80
  dbname           = "wordpress"
  subnet           = data.terraform_remote_state.network.outputs.private_subnets_ids
  target_group_arn = data.terraform_remote_state.network.outputs.lb_target_group_arn
  mysql_url        = data.terraform_remote_state.ECS_RDS.outputs.mysql_url
}