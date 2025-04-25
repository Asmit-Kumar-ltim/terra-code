provider "aws" {
  region = "ap-south-1"
}


#copy ami one account to another account
resource "aws_ami_launch_permission" "dev-account" {
  image_id   = "ami-12345678"
  account_id = "123456789012"       
