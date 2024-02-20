variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc-cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "tenancy" {
  type    = string
  default = "default"
}

variable "true" {
  type    = bool
  default = true
}
