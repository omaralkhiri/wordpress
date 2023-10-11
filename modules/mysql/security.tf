resource "aws_security_group" "Security-RDS"{
    name        = "${var.target_env}-all-rds-mysql-internal"
    description = "${var.target_env} allow all vpc traffic to rds mysql."
    vpc_id      = "${var.vpc_id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks =["${var.myip}/32"] 
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.myip}/32",var.vpc_cidr]
    }
}
