provider "aws" {
  region ="eu-west-2"
}

#Create a VPC

resource "aws_vpc" "second_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
 
    Name = "second_vpc"
  }

}#Create an internet gateway

resource "aws_internet_gateway" "Apache_internet_gateway" {
  vpc_id = aws_vpc.second_vpc.id

  tags = {
    Name = "Second-internetgateway"
  }
}



#Create public route table

resource "aws_route_table" "Second-public-route-table" {
  vpc_id = aws_vpc.second_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Apache_internet_gateway.id
  }


  tags = {
    Name = "Second-public-route-table"
  }

}

#Associate public subnet 01 with public route table

resource "aws_route_table_association" "New-public-subnet01-association" {
  subnet_id      = aws_subnet.New-public-subnet01.id
  route_table_id = aws_route_table.Second-public-route-table.id
}

#Associate public subnet 02 with public route table

resource "aws_route_table_association" "New-public-subnet02-association" {
  subnet_id      = aws_subnet.New-public-subnet02.id
  route_table_id = aws_route_table.Second-public-route-table.id
}


#Create Public Subnet01

resource "aws_subnet" "New-public-subnet01" {
  vpc_id     = aws_vpc.second_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone    ="eu-west-2a"

  tags = {
    Name = "New-public-subnet01"
  }
}


#Create Public Subnet 02

resource "aws_subnet" "New-public-subnet02" {
  vpc_id     = aws_vpc.second_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
    availability_zone    ="eu-west-2b"

  tags = {
    Name = "New-public-subnet02"
  }
}

#Network ACL
resource "aws_network_acl" "First-network-acl" {
  vpc_id = aws_vpc.second_vpc.id
  subnet_ids = [aws_subnet.New-public-subnet01.id, aws_subnet.New-public-subnet02.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

}

#Create a security group for Load Balancer

resource "aws_security_group" "Apache-load_balancer_sg" {
  name        = "Apache-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.second_vpc.id
   
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
    egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creatimg Security Group to allow port 22, 80,443

resource "aws_security_group" "Pache-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for public instances"
  vpc_id      = aws_vpc.second_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Apache-load_balancer_sg.id]
  }

 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Apache-load_balancer_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }  
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   
  }  
  tags = {
    Name = "Pache-security-grp-rule"
  }
}

#Creating EC2 Instances



 resource "tls_private_key" "academia-key" {
 	  algorithm = "RSA"
 	  rsa_bits  = 4096
 	}
 	resource "aws_key_pair" "generated-key" {
 	  key_name = "academia-key"
 	  public_key = tls_private_key.academia-key.public_key_openssh
 	}
 	resource "local_file" "ssh" {
 	  content = tls_private_key.academia-key.private_key_pem
 	  filename = "academia-key.pem"
 	  file_permission = 0400
 	}


resource "aws_instance" "web-01" {
  ami           = "ami-0d09654d0a20d3ae2" # eu-west-2
  instance_type = "t2.micro"
  key_name        = "academia-key"
  security_groups = [aws_security_group.Pache-security-grp-rule.id]
  subnet_id       = aws_subnet.New-public-subnet01.id
  availability_zone = "eu-west-2a"

  tags = {
    "Name" = "Apache-01"
  }

  provisioner "local-exec" {
      command = "echo '${self.public_ip}' >> ./host-inventory"
    }
}
 
resource "aws_instance" "web-02" {
  ami           = "ami-0d09654d0a20d3ae2" # eu-west-2
  instance_type = "t2.micro"
  key_name        = "academia-key"
  security_groups = [aws_security_group.Pache-security-grp-rule.id]
  subnet_id       = aws_subnet.New-public-subnet02.id
  availability_zone = "eu-west-2b"
  tags = {
    "Name" = "Apache-02"
  }

  provisioner "local-exec" {
      command = "echo '${self.public_ip}' >> ./host-inventory"
    }
}
resource "aws_instance" "web-03" {
  ami           = "ami-0d09654d0a20d3ae2" # eu-west-2
  instance_type = "t2.micro"
  key_name        = "academia-key"
  security_groups = [aws_security_group.Pache-security-grp-rule.id]
  subnet_id       = aws_subnet.New-public-subnet01.id
  availability_zone = "eu-west-2a"

  tags = {
    "Name" = "Apache-03"
  }

  provisioner "local-exec" {
      command = "echo '${self.public_ip}' >> ./host-inventory"
    }
}
 
 

# Create an Application Load Balancer

resource "aws_lb" "Apache-load-balancer" {
  name               = "Apache-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Apache-load_balancer_sg.id]
  subnets            = [aws_subnet.New-public-subnet01.id, aws_subnet.New-public-subnet02.id]
  #enable_cross_zone_load_balancing = true
  enable_deletion_protection = false
  depends_on                 = [aws_instance.web-01, aws_instance.web-02, aws_instance.web-03]
}

# Create the target group

resource "aws_lb_target_group" "pache-target-group" {
  name     = "pache-target-group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.second_vpc.id
    health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# Create the listener

resource "aws_lb_listener" "First-listener" {
  load_balancer_arn = aws_lb.Apache-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
   default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pache-target-group.arn
  }
}

# Create the listener rule
 resource "aws_lb_listener_rule" "pache-listener-rule" {
  listener_arn = aws_lb_listener.First-listener.arn
  priority     = 1 
   action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pache-target-group.arn
  }  
  condition {
    path_pattern {
      values = ["/"]
    }
  }
 }


# Attach the target group to the load balancer

resource "aws_lb_target_group_attachment" "Apache-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.pache-target-group.arn
  target_id        = aws_instance.web-01.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "Apache-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.pache-target-group.arn
  target_id        = aws_instance.web-02.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "Apache-target-group-attachment3" {
  target_group_arn = aws_lb_target_group.pache-target-group.arn
  target_id        = aws_instance.web-03.id
  port             = 80 
  
  }

