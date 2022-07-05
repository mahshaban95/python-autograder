terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.20.1"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "default"
  region = "us-west-2"
}

resource "aws_instance" "autograder-instance" {
    ami = "ami-098e42ae54c764c35"
    instance_type   = "t2.micro"
    key_name = "autograder-key"
    connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = "${file("~/.ssh/pet1")}"
        host = "${self.public_ip}"
    }
    provisioner "file" {
        source      = "docker-compose.yml"
        destination = "/home/ec2-user/docker-compose.yml"
    }
    user_data = file("file.sh")

    # provisioner "remote-exec" {
    #     inline = [
    #     "sudo yum install -y yum-utils",
    #     "sudo amazon-linux-extras install docker",
    #     "sudo service docker start",
    #     "sudo usermod -a -G docker ec2-user",
    #     "sudo chkconfig docker on",
    #     "sudo yum install -y git",
    #     "sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
    #     "sudo chmod +x /usr/local/bin/docker-compose",
    #     "sudo systemctl enable docker",
    #     "cd /home/ec2-user",
    #     "docker-compose up -d",
    #     ]
    # }
    
    security_groups = [ "autograder-sg" ]

    tags = {
        Project = "Pet Project #1"
    }

}

resource "aws_key_pair" "autograder-key" {
  key_name   = "autograder-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDINqMD1AqxnpsQRRermqE8gKR2L5BGvDoiRysthTEoIXJlgFsxIQS84sU0uul6cCFzD91hZx7f6Y3zEAVID52mzWlFw29DVGqA+lJ3q1Ph3yLLVvgJSo0O6Ek615GHHBJ/bRssjxpAjpuw3gR8Hit58fRXNzO8JTdUD8eQIbuqdOy2aLzl093bSgObB3raBn3IjsbSAgScmOG8JbWhc2Zlur7OB2AMjvMYqPWqM7djsEDRHfrwDRcODMsDYfq8pSoFzU/kplL1u91oCWOi+JDeoGP5k25ebYLhzXRRK95oBm4dghppq39OR2/P4mYDgGSOrP8cUcQxZe+f/0NWUV0P vagrant@vagrant"
}

resource "aws_security_group" "autograder-sg" {
  name        = "autograder-sg"
  ingress {
      description      = "HTTP from anywhere"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ingress {
      description      = "SSH from anywhere"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  egress {
      description      = "Allow to anywhere"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  

  tags = {
    Project = "Pet Project #1"
  }
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.autograder-instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS address of the EC2 instance"
  value       = aws_instance.autograder-instance.public_dns
}