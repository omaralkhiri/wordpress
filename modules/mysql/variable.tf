variable "db_name" {
  description = "The name of the database to be created."
}

variable "username" {
  description = "The username for the database."
}

variable "password" {
  description = "The password for the database user."
}

variable "instance_type" {
  description = "The instance type to be used for the PostgreSQL instance."
}

variable "identifier" {}
variable "vpc_cidr" {}
variable "vpc_id" {}
variable "target_env" {}
variable "database_subnets" {}
variable "skip_final_snapshot"{}
variable "myip" {}