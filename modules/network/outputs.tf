# These outputs will be used in other files.

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub-sub-1" {
  value = aws_subnet.public-subnet-1.id
}

output "pub-sub-2" {
  value = aws_subnet.public-subnet-2.id
}

output "private-sub-1" {
  value = aws_subnet.private-subnet-1.id
}

output "private-sub-2" {
  value = aws_subnet.private-subnet-2.id
}

output "load_balancer_ip" {
  value = aws_lb.lb.dns_name
}