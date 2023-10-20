output "mysql_url" {
  value = aws_db_instance.mysql.endpoint
}
output "password" {
  value = random_string.password.result
}