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