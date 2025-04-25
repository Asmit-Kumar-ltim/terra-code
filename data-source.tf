data "aws_ami" "amazon-linux2" {
  most_recent = true
  owners      = ["amazon"]
 
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
  }
 
 
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
