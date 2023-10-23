# Determine the location of the database server and increase the security of the server
resource "aws_db_subnet_group" "subnet_group" {
  name        = "${var.target_env}-rds-mssql-subnet-group"
  subnet_ids  = [var.database_subnets]
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = "your-secret-name"  
}

# storage_encrypted to encrypte data in database 
resource "aws_db_instance" "mysql" {
  allocated_storage             = 10
  db_name                       = var.db_name
  engine                        = "mysql"
  engine_version                = "5.7"
  instance_class                = var.instance_type
  username                      = sensitive(data.aws_secretsmanager_secret_version.rds_credentials.secret["username"])
  password                      = sensitive(data.aws_secretsmanager_secret_version.rds_credentials.secret["password"])
  identifier                    = var.identifier
  parameter_group_name          = "default.mysql5.7"
  publicly_accessible           = true
  vpc_security_group_ids  = ["${aws_security_group.Security-RDS.id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.subnet_group.id}"
  storage_encrypted = true
}