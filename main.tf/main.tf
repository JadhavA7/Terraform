terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      version = "~>3.1"
    }
  }
}
provider "aws" {
   region = "ap-south-1"
}
resource "aws_instance" "myec2" {
 
     ami = "ami-00bb6a80f01f03502"
     instance_type = "t2.micro"
}
