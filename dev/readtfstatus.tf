# This is used to block the terraform state storage block to avoid deleting the file by mistake, and it is also used to avoid interference between those working on the files.
terraform {
  backend "s3" {
    bucket = "ECS_RDS"
    key    = "Ecs/terraform.tfstate"
    region = "eu-central-1"
  }
}