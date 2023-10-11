
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.target_env}-vpc"
    Env = var.target_env
  }
}
# create internet gateway to access internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.target_env}-igw"
    Env = var.target_env
  }
}

# add internet gateway to route table
resource "aws_default_route_table" "default-route-table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name= "${var.target_env}-default-route-table"
    Env = var.target_env
  }
}

# Elastic ip for private subnet
resource "aws_eip" "nat_gateway_eip" {
  domain                    = "vpc"
  tags = {
    Name = "${var.target_env}-nat-gateway-eip"
  }
}

# create nat gateway to make private subnet Download any resource if need
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "${var.target_env}-nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# This step to add nat gateway to route table
resource "aws_route_table" "nat_gateway_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.target_env}-nat-gateway-route-table"
  }
}

# create two private subnet in vpc
resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.priv_sub1_cidr_block
  availability_zone = var.availability_zone_1
  tags = {
    Name = "${var.target_env}-private-subnet-1"
    Env = var.target_env
  }
}
resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.priv_sub2_cidr_block
  availability_zone = var.availability_zone_2
  tags = {
    Name = "${var.target_env}-private-subnet-2"
    Env = var.target_env
  }
}

# create two public subnet in vpc with different availability zone (This is a case that is useful for balance load)
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_sub1_cidr_block
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.target_env}-public-subnet-1"
    Env = var.target_env
  }
}
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pub_sub2_cidr_block
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.target_env}-public-subnet-2"
    Env = var.target_env
  }
}

# Provides security for communication between subgroups and routing tables, this can contribute to improving the overall security of the infrastructure
resource "aws_route_table_association" "pri_sub_1_nat_route_table_assoc" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

resource "aws_route_table_association" "pri_sub_2_nat_route_table_assoc" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

# Achieving efficient and sustainable workload distribution on the infrastructure
resource "aws_lb" "lb" {
  name            = "lb"
  subnets         = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
  security_groups = [aws_security_group.lb.id]
}

# Monitor the health of servers or services and route traffic to the servers
resource "aws_lb_target_group" "lb_target_group" {
  name        = "lb_target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.id
    type             = "forward"
  }
}