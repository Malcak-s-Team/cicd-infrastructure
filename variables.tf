variable "region" {
  description = "Default region to deploy"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "CI"
}

variable "project" {
  description = "Project Name"
  type        = string
  default     = "ci"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(any)
  default     = ["22", "8080", "80", "443"]
}

variable "aws_access_key_id" {
  description = "aws access key id"
  type        = string
}
variable "aws_secret_access_key" {
  description = "aws secret access key"
  type        = string
}
