provider "aws" {
  region     = "us-east-2"
  access_key = "Access ID"
  secret_key = "secret ID"
}

#Create a VPC
resource "aws_vpc" "prodvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "production_vpc"
  }
}

# Create a Subnet

resource "aws_subnet" "prodsubnet1" {
  vpc_id     = aws_vpc.prodvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Prod-Subnet"
  }
}
#Create a Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id     = aws_vpc.prodvpc.id

  tags = {
    Name = "IGW"
  }
}

#Create a Route Table
resource "aws_route_table" "prodroute" {
  vpc_id     = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "RouteTable"
  }
}

#Associate the subnet with the Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prodsubnet1.id
  route_table_id = aws_route_table.prodroute.id
}


#Create a security Group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id     = aws_vpc.prodvpc.id

ingress  {
    description     = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp" 
    cidr_blocks      = ["0.0.0.0/0"]
    
  }


  ingress  {
    description     = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp" 
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress  {
    description     = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp" 
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # any protocol or any ip address
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  tags = {
    Name = "allow_tls"
  }
}


#Create an Instance, add security group to the instance 
resource "aws_instance" "server" {
  ami                     = "ami-0ea3c35c5c3284d82"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.prodsubnet1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name   = "ohio_new_kp"
  
  tags = {
    Name = "Ubuntu-Server"
  }

}


resource "aws_instance" "server2" {
  ami                     = "ami-0ea3c35c5c3284d82"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.prodsubnet1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name   = "ohio_new_kp"
  
  tags = {
    Name = "Amazon_Linux-Server"
  }

}
