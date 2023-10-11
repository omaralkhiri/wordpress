module "wordpress" {
  source           = "../modules/ECS"
  container_name   = "wordpress"
  image            = "wordpress:latest"
  containerport    = 80
  hostport         = 80
  dbname           = "wordpress"
  username         = "mysql"
  password         = "lKpyyZfY7wmY7Faz0imzFFF"
  subnet           = [module.network.private-sub-1,module.network.private-sub-2]
  target_group_arn = module.network.lb_target_group_arn
  mysql_url        = module.mysql.mysql_url
  depends_on       = [ module.mysql,module.network ]
}