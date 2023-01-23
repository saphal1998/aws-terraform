aws_region     = "us-east-1"
aws_ami        = "<your-ami>"
aws_key_name   = "project-key"
aws_instance_tags = {
  name = "project-name"
  project = "project-name"
}

# Instance capacity
aws_gp2_storage_capacity_in_gigs = 10
# Instance type
aws_instance_type = "t3.micro"
