resource "aws_vpc" "devops_lab_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "DevOpsLabVPC - DG"
  }
}

resource "aws_subnet" "devops_lab_subnet" {
  vpc_id            = aws_vpc.devops_lab_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "DevOpsLabSubnet - DG"
  }
}


resource "aws_security_group" "devops_lab_sg" {
  name        = "DevOpsLabSG - DG"
  description = "SG para API DevOps Lab"
  vpc_id      = aws_vpc.devops_lab_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "DevOpsLabSG - DG"
  }
}

resource "aws_instance" "devops_lab_ec2-DG" {
  ami           = "ami-052064a798f08f0d3" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.devops_lab_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_lab_sg.id]
  key_name      = "DevOpsLabKeyDG"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    sleep 15 
    systemctl status docker || systemctl restart docker
    docker pull doug190/devops-lab-api:latest
    docker run -d -p 5000:5000 doug190/devops-lab-api:latest
  EOF

  tags = {
    Name = "DevOpsLabEC2-DG"
  }
}
