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