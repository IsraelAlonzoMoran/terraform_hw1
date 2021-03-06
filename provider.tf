terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "terraform-vpc" {
  cidr_block ="172.30.0.0/16"
  instance_tenancy ="default"

  tags = {
    "Name" = "israelalonzo-terraform-vpc"
  }
}

#Create a Internet Gateway
resource "aws_internet_gateway" "terraform-internet-gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    "Name" = "israelalonzo-terraform-internet-gw"
  }
}

#Create 3 public subnets:
#Create israelalonzo-terraform-public-subnet-1
resource "aws_subnet" "terraform-public-subnet-1" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "172.30.0.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "israelalonzo-terraform-public-subnet-1"
  }
}

#Create israelalonzo-terraform-public-subnet-2
resource "aws_subnet" "terraform-public-subnet-2" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "172.30.1.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "israelalonzo-terraform-public-subnet-2"
  }
}

#Create israelalonzo-terraform-public-subnet-3
resource "aws_subnet" "terraform-public-subnet-3" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "172.30.2.0/24"
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "israelalonzo-terraform-public-subnet-3"
  }
}
#Create 3 private subnets:
#Create israelalonzo-terraform-private-subnet-1
resource "aws_subnet" "terraform-private-subnet-1" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "172.30.3.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "israelalonzo-terraform-private-subnet-1"
  }
}

#Create israelalonzo-terraform-private-subnet-2
resource "aws_subnet" "terraform-private-subnet-2" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "172.30.4.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "israelalonzo-terraform-private-subnet-2"
  }
}

#Create israelalonzo-terraform-private-subnet-3
resource "aws_subnet" "terraform-private-subnet-3" {
  vpc_id                  = aws_vpc.terraform-vpc.id
  availability_zone       = "us-west-2c"
  cidr_block              = "172.30.5.0/24"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "israelalonzo-terraform-private-subnet-3"
  }
}

#Create 2 RouteTables (1 Public, 1 Private)
#Create israelalonzo-terraform-public-route-table-1
resource "aws_route_table" "terraform-public-route-table-1" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-internet-gw.id

  }

  tags = {
    Name = "israelalonzo-terraform-public-route-table-1"
  }
}

#Create israelalonzo-terraform-public-route-table-1 with israelalonzo-terraform-public-subnet-1
resource "aws_route_table_association" "terraform-public-route-table-1-with-public-subnet-1" {
  subnet_id      = aws_subnet.terraform-public-subnet-1.id
  route_table_id = aws_route_table.terraform-public-route-table-1.id

}

#Create israelalonzo-terraform-public-route-table-1 with israelalonzo-terraform-public-subnet-2
resource "aws_route_table_association" "terraform-public-route-table-1-with-public-subnet-2" {
  subnet_id      = aws_subnet.terraform-public-subnet-2.id
  route_table_id = aws_route_table.terraform-public-route-table-1.id

}

#Create israelalonzo-terraform-public-route-table-1 with israelalonzo-terraform-public-subnet-3
resource "aws_route_table_association" "terraform-public-route-table-1-with-public-subnet-3" {
  subnet_id      = aws_subnet.terraform-public-subnet-3.id
  route_table_id = aws_route_table.terraform-public-route-table-1.id

}

#Create an Elastic IP that is required to create a NAT Gateway
#Allocate Elastic IP Address
resource "aws_eip" "terraform-eip-for-nat-gw" {
  vpc = true
  tags = {
    "Name" = "israelalonzo-terraform-eip-for-nat-gw"
  }
}

#Create a NAT Gateway
resource "aws_nat_gateway" "terraform-nat-gw" {
  allocation_id = aws_eip.terraform-eip-for-nat-gw.id
  subnet_id     = aws_subnet.terraform-public-subnet-1.id
  depends_on    = [aws_internet_gateway.terraform-internet-gw]
}

#Create israelalonzo-terraform-private-route-table-1
resource "aws_route_table" "terraform-private-route-table-1" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform-nat-gw.id
  }

  tags = {
    Name = "israelalonzo-terraform-private-route-table-1"
  }
}

#Create israelalonzo-terraform-private-route-table-1 with israelalonzo-terraform-private-subnet-1
resource "aws_route_table_association" "terraform-private-route-table-1-with-private-subnet-1" {
  subnet_id      = aws_subnet.terraform-private-subnet-1.id
  route_table_id = aws_route_table.terraform-private-route-table-1.id

}

#Create israelalonzo-terraform-private-route-table-1 with israelalonzo-terraform-private-subnet-2
resource "aws_route_table_association" "terraform-private-route-table-1-with-private-subnet-2" {
  subnet_id      = aws_subnet.terraform-private-subnet-2.id
  route_table_id = aws_route_table.terraform-private-route-table-1.id

}

#Create israelalonzo-terraform-private-route-table-1 with israelalonzo-terraform-private-subnet-3
resource "aws_route_table_association" "terraform-private-route-table-1-with-private-subnet-3" {
  subnet_id      = aws_subnet.terraform-private-subnet-3.id
  route_table_id = aws_route_table.terraform-private-route-table-1.id

}