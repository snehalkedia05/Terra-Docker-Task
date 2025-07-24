variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair"
}
