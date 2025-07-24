provider "aws" {
  region = "us-east-1" # You can change this as needed
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet("10.0.1.0/24", 2, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet("10.0.100.0/24", 2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "PrivateSubnet-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP, SSH and custom port"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "WebSecurityGroup"
  }
}

resource "aws_instance" "ubuntu_instance" {
  ami                    = ""ami-053b0d53c279acc90" "  # Replace with valid Ubuntu AMI in your region
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "newk"  # Your key pair name in AWS

  tags = {
    Name = "UbuntuInstance"
  }
}

output "ec2_public_ip" {
  value       = aws_instance.ubuntu_instance.public_ip
  description = "Public IP of the EC2 instance"
}
