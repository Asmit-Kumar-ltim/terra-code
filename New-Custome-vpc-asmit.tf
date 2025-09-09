provider "aws" {
  region = "us-east-1"

}

# Security Group
resource "aws_security_group" "asmit-sg" {
        name = "asmit-sg"
        description = "allow ssh and http"
        vpc_id = aws_vpc.asmit-vpc.id

        ingress {
                from_port = 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}

# VPC
resource "aws_vpc" "asmit-vpc" {
  cidr_block = "10.0.0.0/16"
}

# IGW
resource "aws_internet_gateway" "asmit-igw" {
  vpc_id = aws_vpc.asmit-vpc.id

  tags = {
    Name = "asmit-igw"
  }
}

# Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.asmit-vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/24"

  tags = {
    Name = "Public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.asmit-vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "Private-subnet"
  }
}

# Route Table (Public)
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.asmit-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.asmit-igw.id
  }


  tags = {
    Name = "public-rt"

  }
}

# Attching route table to public subnet
resource "aws_route_table_association" "public-asso" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

# Creating an instance (web server)
resource "aws_instance" "asmit-server" {
  ami             = "ami-00ca32bbc84273381"
  subnet_id       = aws_subnet.public-subnet.id
  instance_type   = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.asmit-sg.id}"]
  key_name        = "ltitestkey"
  tags = {
    Name     = "web-server"
    Stage    = "testing"
    Location = "Mumbai"
  }
}

# Giving eip to web server instance
resource "aws_eip" "asmit-ec2-eip" {
  instance = aws_instance.asmit-server.id
}

# Creating key-pair
resource "aws_key_pair" "ltimindtree" {
  key_name   = "ltitestkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPe2zj10tC2ZUNwsO07FAOdDAgWzDXsEPkmVNvfb7Z8nY5a2111YV+w2w+AyQFDqEqhZ77iggFrJtqbXmDvCBMiLZAxXqIalQmzdB3RJgdvqKi5CZ83uI0FAJVd5VW7g8W2mhfyjqm2aKf/CdCYJ5pAXnQfZwC/3PVGvy3an1lpWJFiX+7k4A4qFQVvwoh7fXPrfNtZ1jO5OTkdFvRr4azQYstGM+gNvtBO645+DeDkJzOSG737fUiZnEcil0id3qvkpsIO2PyW93Ve3oGupmUqvwy0WFGgZ1a9jbeubifVip8FAILC+p9KF3/gGoQEmftN5P99WWRAi5W4b9Gkw5QePXc7Tv4k8RwybsvECv8zMu9Jhsr/F10nRHS2V46IrsRckm98ficGcx48Jc/lgPdFYrSzUZ4FGxt98VYp0H9H6TXBwsYTtAe/6XSzVaw2SBqzrWkpZc8rFICtYnRKg76fGdEpMOEeeu533WtYoazBHt8PY+Sca9GC0bIj7Xix+U= root@terra"
}

# Creating a db server instance
resource "aws_instance" "database-server" {
  ami             = "ami-00ca32bbc84273381"
  subnet_id       = aws_subnet.private-subnet.id
  instance_type   = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.asmit-sg.id}"]
  key_name        = "ltitestkey"
  tags = {
    Name     = "db-server"
    Stage    = "stage-base"
    Location = "Kolkata"
  }
}

resource "aws_eip" "nat-eip" {
}

# Creating NAT Gateway
resource "aws_nat_gateway" "my-ngw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet.id
}

# Creating private Route Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.asmit-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-ngw.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Assigning pvt rt with pvt subnet
resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}
                      
