terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Random suffix for unique names
resource "random_id" "suffix" {
  byte_length = 4
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "web" {
  name        = "${var.env_prefix}-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-web-sg"
  }
}

# Key Pair
resource "aws_key_pair" "key" {
  key_name   = "${var.env_prefix}-key-${random_id.suffix.hex}"
  public_key = var.public_key
}

# Frontend Instance
resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "${var.env_prefix}-frontend"
  }
}

# Backend Instances
resource "aws_instance" "backend" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.key.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "${var.env_prefix}-backend-${count.index}"
  }
}

# Generate Ansible inventory
data "template_file" "hosts" {
  template = file("${path.module}/ansible/inventory/hosts.tpl")
  vars = {
    frontend_ip = aws_instance.frontend.public_ip
    backend_ips = join("\n", [for b in aws_instance.backend : b.public_ip])
    private_key = var.private_key
  }
}

resource "local_file" "hosts" {
  content  = data.template_file.hosts.rendered
  filename = "${path.module}/ansible/inventory/hosts"
}

# Ansible run
resource "null_resource" "ansible_config" {
  triggers = {
    frontend_ip = aws_instance.frontend.public_ip
    backend_ips = join(",", [for b in aws_instance.backend : b.public_ip])
  }

  depends_on = [
    aws_instance.frontend,
    aws_instance.backend,
    local_file.hosts
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd ansible
      ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventory/hosts playbooks/site.yaml
    EOT
  }
}