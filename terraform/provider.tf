#
# Provides IDs for resources created from this main Terraform repo
#
# Usage
#   - Copy the plugins to your Terraform directory by copying the
#     contents of (terraform repo)\plugins to the path where your
#     Terraform.exe is located, which you can get by `which terraform`
#     on linux, or `Get-Command terraform.exe` in Powershell.
#   - Run `terraform init` in your project's terraform directory to
#     install any provider plugins.
#

provider "aws" {
  region  = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  version = "~> 1.20.0"
}

variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "acct" {
  type = "map"
  default = {
    account-id    = "123972417721"
    region        = "us-east-1"
    abbrev        = "personal"
    dnsabbrev     = "personal"
  }
}

variable "vpc-id" {
  default = "vpc-c78586bc"
}

variable "instance-sg-id" {
  default = "sg-8b0b50c3"
}

variable "task-sg-id" {
  default = "sg-3fe6be77"
}

variable "alb-sg-id" {
  default = "sg-6e144f26"
}

variable "private-subnet-ids" {
  type = "list"
  default = [
    "subnet-48549a66",
    "subnet-11cb585b"]
}

variable "public-subnet-ids" {
  type = "list"
  default = [
    "subnet-1c6ea032",
    "subnet-6aca5920"]
}

variable "r53-zone-id" {
  default = "Z2XDO2GUXTPGFX"
}

variable "container" {
  type = "map"
  default = {
    "cpu" = "256"
    "memory" = "512"
    "port" = 443
    "count" = 2
  }
}

variable "alb-access-log-bucket" {
  default = "drax-tombartolucci-io-alb-logs"
}

variable "ec2_keypair_name" {
  default = "tom-desktop-key-pair"
}

data "aws_vpc" "default" {
  id = "vpc-07df587e"
}

variable "tombartolucci_io_cert" {
  default = "arn:aws:acm:us-east-1:123972417721:certificate/91921ed3-71a8-4633-9177-9be151693092"
}

variable "tombartolucci_hostname" {
  default = "tombartolucci.io"
}

variable "tombartolucci_zone" {
  default = "tombartolucci.io."
}
