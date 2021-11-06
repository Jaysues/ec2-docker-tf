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