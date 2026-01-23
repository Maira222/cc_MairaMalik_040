variable "project_name" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
}

variable "bucket_domain_name" {
  description = "S3 bucket domain name"
  type        = string
}

variable "oai_id" {
  description = "CloudFront Origin Access Identity ID"
  type        = string
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
}

variable "enable_logging" {
  description = "Enable logging"
  type        = bool
}

variable "logging_bucket" {
  description = "Logging bucket"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}