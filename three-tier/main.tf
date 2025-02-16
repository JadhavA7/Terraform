terraform {
  required_version = "~> 1.1"
  required_providers {
    aws = {
      version = "~>3.1"
    }
  }
}

provider "aws" {
   region = var.my_region
   access_key = var.access_key
   secret_key = var.secret_key
} 
resource "aws_vpc" "costumvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.costumvpc.id

  tags = {
    Name = "my-igw"
  }
}
resource "aws_subnet" "web-subnet" {
  vpc_id     = aws_vpc.costumvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "web-subnet"
  }
}
resource "aws_subnet" "app-subnet" {
  vpc_id     = aws_vpc.costumvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "app-subnet"
  }
}
resource "aws_subnet" "db-subnet" {
  vpc_id     = aws_vpc.costumvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "db-subnet"
  }
}
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.costumvpc.id
  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id =  aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.costumvpc.id
  tags = {
    Name = "pvt-rt"
  }
}
resource "aws_route_table_association" "web-assoc" {
  subnet_id      = aws_subnet.web-subnet.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "app-assoc" {
  subnet_id      = aws_subnet.app-subnet.id
  route_table_id = aws_route_table.pvt-rt.id
}
resource "aws_route_table_association" "db-assoc" {
  subnet_id      = aws_subnet.db-subnet.id
  route_table_id = aws_route_table.pvt-rt.id
}
resource "aws_security_group" "web-sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.costumvpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
     cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
ingress {
     cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
}
resource "aws_security_group" "app-sg" {
  name   = "app-sg"
  vpc_id = aws_vpc.costumvpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    cidr_blocks = ["10.0.0.0/24"]
    from_port   = 9000
    protocol    = "tcp"
    to_port     = 9000
  }
}

resource "aws_security_group" "db-sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.costumvpc.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    cidr_blocks = ["10.0.1.0/24"]
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }
}
resource "aws_instance" "web" {
  ami                    = var.my_ami
  instance_type          = var.ins_type
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id = aws_subnet.web-subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "webserver"
  }
  key_name = "mytf-key1"
}
resource "aws_instance" "app" {
  subnet_id = aws_subnet.app-subnet.id
  ami                    = var.my_ami
  instance_type          = var.ins_type
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  tags = {
    Name = "appserver"
 }
  key_name = "mytf-key1"
}
resource "aws_db_instance" "my-rds" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "Pass1234"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.my-subnet-grp.name
  skip_final_snapshot  = true
}
resource "aws_db_subnet_group" "my-subnet-grp" {
  name       = "my-sub-grp"
  subnet_ids = [aws_subnet.app-subnet.id, aws_subnet.db-subnet.id]
 
  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "mytf-key1"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "mytf-key1"
}
