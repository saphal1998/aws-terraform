terraform {
  required_version = ">=1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.51.0"
    }
  }
}

variable "aws_instance_type" {
  type = string
  description = "The AWS instance type to deploy"
}

variable "aws_gp2_storage_capacity_in_gigs" {
  type = number
  description = "The amount of gp2 storage to put in the AWS instance"
}


variable "aws_region" {
  description = "The AWS region to deploy to"
  type = string
}

variable "aws_ami" {
  description = "The AWS AMI to deploy"
  type = string
}

variable "aws_key_name" {
 description = "The AWS key name to deploy"
 type = string 
}

variable "aws_instance_tags" {
  description = "The AWS Tags that need to be attached"
  type = object({
    project = string
    name = string 
  })
}

provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "kp" {
  key_name = var.aws_key_name
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > './${var.aws_key_name}.pem'"
  }
}

resource "aws_security_group" "student_ami_sg" {
   # inbound internet access
   # allowed: only port 22, 80 is open
   # you are NOT allowed to open all the ports to the public
   ingress {
     from_port = 22
     to_port   = 22
     protocol  = "tcp"

     cidr_blocks = [
       "0.0.0.0/0",
     ]
   }

   ingress {
     from_port = 80
     to_port   = 80
     protocol  = "tcp"

     cidr_blocks = [
       "0.0.0.0/0",
     ]
   }
   # outbound internet access
   # allowed: any egress traffic to anywhere
   egress {
     from_port = 0
     to_port   = 0
     protocol  = "-1"

     cidr_blocks = [
       "0.0.0.0/0",
     ]
   }
 }

 resource "aws_instance" "cmucc_aws_instance" {
   ami                    = var.aws_ami
   instance_type          = var.aws_instance_type 
   vpc_security_group_ids = [aws_security_group.student_ami_sg.id]
   tags = var.aws_instance_tags 
   root_block_device {
     volume_size = var.aws_gp2_storage_capacity_in_gigs
     volume_type = "gp2"
   }
   key_name = var.aws_key_name
 }

output "public_dns" {
  description = "The public dns of the newly created instance"
  value = aws_instance.cmucc_aws_instance.public_dns
}
