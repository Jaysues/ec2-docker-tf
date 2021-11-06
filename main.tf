provider "aws" {
  region = "ap-southeast-2"
}
#Below is the block for variables
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}
#below is the block for resources relating to VPC/Subnets/RTB/IGW
resource "aws_vpc" "dev_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}
#Currently only one subnet for dev
resource "aws_subnet" "dev_private" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}
# Below is for a newly created route table as opposed to the normal generated one.
# resource "aws_route_table" "myapp_route_table" {
#   vpc_id = aws_vpc.dev_vpc.id
#   route {
#       cidr_block = "0.0.0.0/0"
#       gateway_id = aws_internet_gateway.myapp_internet_gateway.id
#   }
#   tags = {
#       Name: "${var.env_prefix}-rtb"
#   }
# }

# resource "aws_route_table_association" "a_rtb_subnet" {
#   subnet_id = aws_subnet.dev_private.id
#   route_table_id = aws_route_table.myapp_route_table.id
# }

#New IGW 
resource "aws_internet_gateway" "myapp_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}
#this is the generic main route table
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.dev_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_internet_gateway.id
  }
  tags = {
    Name : "${var.env_prefix}-main-rtb"
  }
}
#this is the generic security group
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name : "${var.env_prefix}-default-sg"
  }
}

resource "aws_instance" "myapp_server" {
#these are required
  ami           = data.aws_ami.amazon_linux_2_latest_image.id
  instance_type = var.instance_type
#these are not
  subnet_id                   = aws_subnet.dev_private.id
  vpc_security_group_ids      = [aws_default_security_group.default_sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name
  #userdata component
  user_data = file("dockerbootstrap-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}
resource "aws_key_pair" "ssh_key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}

#data blocks
data "aws_ami" "amazon_linux_2_latest_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#outputs
output "vpc-id" {
  value = aws_vpc.dev_vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev_private
}

output "aws_ami_id" {
  value = data.aws_ami.amazon_linux_2_latest_image.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp_server.public_ip
}
