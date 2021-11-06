#New IGW 
resource "aws_internet_gateway" "myapp_internet_gateway" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}