variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "Invalid CIDR"
  }
}

variable "subnet_cidr_block" {
  type        = string
  description = "CIDR for subnet"
}

variable "availability_zone" {
  type = string
}

variable "env_prefix" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_key" {
  type = string
}

variable "private_key" {
  type = string
}





