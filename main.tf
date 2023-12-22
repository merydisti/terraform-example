# Set the AWS provider configuration
provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create a subnet inside the VPC
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Set your desired availability zone
}

# Create a security group for allowing traffic
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a Redis instance
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"

  subnet_group_name = aws_subnet.main.id
  security_group_ids = [aws_security_group.allow_all.id]
}

# Create a PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
  identifier            = "my-postgres-db"
  engine                = "postgres"
  instance_class        = "db.t2.micro"
  allocated_storage     = 5
  username              = "myuser"
  password              = "mypassword"
  db_subnet_group_name  = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
}

# Create an ECS cluster for Docker
resource "aws_ecs_cluster" "docker_cluster" {
  name = "docker-cluster"
}
