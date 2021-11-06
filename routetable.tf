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