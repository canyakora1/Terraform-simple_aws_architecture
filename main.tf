# Create a VPC
resource "aws_vpc" "kids_castle" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Kids_Castle"
  }
}

# Create public and private subnets
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.kids_castle.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Public_subnet"
  }
}

resource "aws_subnet" "private_app_subnet" {
  vpc_id     = aws_vpc.kids_castle.id
  cidr_block = "10.0.2.0/24"
  tags = {
    "Name" = "Private_app_subnet"
  }
}

resource "aws_subnet" "private_db_subnet" {
  vpc_id     = aws_vpc.kids_castle.id
  cidr_block = "10.0.3.0/24"
  tags = {
    "Name" = "Private_db_subnet"
  }

}

# Create an internet gateway
resource "aws_internet_gateway" "castle_igw" {
  vpc_id = aws_vpc.kids_castle.id
}

# Create a NAT gateway and ELP aalocation
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat_eip"
  }
}
resource "aws_nat_gateway" "private_nat_gw" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_subnet.id
  allocation_id     = aws_eip.nat_eip.id

  tags = {
    Name = "private_nat_gw"
  }
  depends_on = [aws_internet_gateway.castle_igw]
}

# Create a route table and associate it with the public subnet
resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.kids_castle.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.castle_igw.id
  }
  tags = {
    Name = "public_rt"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


# Create a private route table and associate it with the private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.kids_castle.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_nat_gw.id
  }
}
resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_rt.id

}
# Create security groups
resource "aws_security_group" "web_sg" {
  name_prefix = "web-"
  description = "Allow http web traffic"
  vpc_id = aws_vpc.kids_castle.id

  ingress {
    from_port   = 80
    description = "Allow http web traffic from VPC"
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app-"
  description = "Allow traffic from web security group"
  vpc_id = aws_vpc.kids_castle.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "app_sg"
  }
}

resource "aws_security_group" "db_sg" {
  name_prefix = "db-"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  tags = {
    Name = "db_sg"
  }
}

# Launch EC2 instances
resource "aws_instance" "web-server" {
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = <<EOF
              #!/bin/bash
              echo "Hello from web instance" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF

  tags = {
    Name = "web"
  }
}

resource "aws_instance" "app_server" {
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_app_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = <<EOF
              #!/bin/bash
              echo "Hello from app instance" > index.html
              nohup python -m SimpleHTTPServer 8080 &
              EOF

  tags = {
    Name = "app_server"
  }
}

resource "aws_instance" "db_server" {
  ami                    = "ami-022e1a32d3f742bd8"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_db_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = <<EOF
              #!/bin/bash
              echo "Hello from app instance" > index.html
              nohup python -m SimpleHTTPServer 8080 &
              EOF

  tags = {
    Name = "db_server"
  }

}
