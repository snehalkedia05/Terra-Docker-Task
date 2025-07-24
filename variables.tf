variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "key_pair_name" {
  description = "Your AWS EC2 key pair name"
  default     = "your-keypair-name" # ← change this to your key name
}
