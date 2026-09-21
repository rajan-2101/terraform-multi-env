variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "ami_name_filter" {
  type    = string
  default = "al2023-ami-2023*-x86_64"
}
