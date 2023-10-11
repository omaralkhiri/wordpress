output "mysql_url" {
  value = [module.mysqlmysql_url]
}
output "private_subnets_ids" {
  value = [module.network.private-sub-1, module.network.private-sub-2]
}
output "public_subnets_ids" {
  value = [module.network.pub-sub-1, module.network.pub-sub-2]
}
output "vpc_id" {
  value = [module.network.vpc_id]
}
output "lb_target_group_arn" {
  value = [module.network.lb_target_group]
}