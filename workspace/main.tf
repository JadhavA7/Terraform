provider "aws" {
  region     = "ap-south-1"
  access_key = var.my_access
  secret_key = var.my_secret
}
resource "aws_instance" "web" {
  ami                    = var.my_ami
  instance_type          = lookup(var.inst_type,terraform.workspace)
  tags = {
    Name = "myserver"
  }
}
