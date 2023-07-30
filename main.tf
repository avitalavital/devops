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
# Create a local file to write the public IP address
resource "local_file" "public_ip_test_file" {
  filename = "public_ip_test.txt"
  content  = aws_instance.test.public_ip
}
# Create a local file to write the public IP address
resource "local_file" "public_ip_prod_file" {
  filename = "public_ip_prod.txt"
  content  = aws_instance.prod.public_ip
}
