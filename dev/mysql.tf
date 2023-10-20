module "mysql" {
  source              = "../modules/mysql"
  db_name             = "wordpress"
  username            = "mysql"
  instance_type       = "db.t3.micro"
  identifier          = "wordpress"
  vpc_cidr            = var.vpc_cidr
  skip_final_snapshot = false
  target_env          = var.target_env
  database_subnets    = [module.network.pub-sub-1,module.network.pub-sub-2]
  vpc_id              = module.network.vpc_id
  myip                = var.myip
  depends_on          = [ module.network ]
}