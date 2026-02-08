# AWS Configuration
aws_region  = "us-east-1"
environment = "dev"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# EC2 Configuration
instance_type = "t3.micro"

# IMPORTANT: Replace with your actual SSH key pair name from AWS
# Leave empty if you don't need SSH access
key_name = ""

# AMI ID - Leave empty to use the latest Amazon Linux 2023 automatically
ami_id = ""

# Security Configuration
# IMPORTANT: For production, change this to your specific IP address
# Example: allowed_ssh_cidr = "203.0.113.0/32"
allowed_ssh_cidr = "0.0.0.0/0"

# Project Configuration
project_name = "terraform-pipeline"
