# Configure the AWS provider
provider "aws" {
  region = "eu-north-1"
}

# Define the EC2 instance resource
resource "aws_instance" "test" {
  ami           = "ami-040d60c831d02d41c"
  instance_type = "t3.micro"

  tags = {
    Name = "test"
    Environment = "test"
    Project = "terra-Project"
  }
}

# Output the public IP address of the created EC2 instance
output "public_ip_test" {
  value = aws_instance.test.public_ip
}
# Define the EC2 instance resource
resource "aws_instance" "prod" {
  ami           = "ami-040d60c831d02d41c"
  instance_type = "t3.micro"

  tags = {
    Name = "prod"
    Environment = "prod"
    Project = "terra-Project"
  }
}

# Output the public IP address of the created EC2 instance
output "public_ip_prod" {
  value = aws_instance.prod.public_ip
}
# Create a local file to write both public and private IP addresses
resource "local_file" "ip_addresses_file" {
  filename = "ip_addresses.txt"
  content = <<-EOT
    Public IP: ${aws_instance.test.public_ip}
    Private IP: ${aws_instance.prod.public_ip}
  EOT
}
resource "aws_key_pair" "terraform_key_pair" {
  key_name   = "terraform_key_pair"
  public_key = file("~/.ssh/terraform_key_pair.pub")
}
resource "aws_security_group" "terraform" {
  name        = "terraform-security-group"  # Replace with your desired name for the security group
  description = "terraform security group created by Terraform"

  # Inbound rules
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from any IP address (Note: This is not recommended for production)
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from any IP address (Note: This is not recommended for production)
  }
ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from any IP address (Note: This is not recommended for production)
  }

  # Outbound rules (optional)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
