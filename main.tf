# Configure the AWS provider
provider "aws" {
  region = "eu-north-1"
}

# Define the EC2 instance resource
resource "aws_instance" "example" {
  ami           = "ami-040d60c831d02d41c"
  instance_type = "t3.micro"
}

# Output the public IP address of the created EC2 instance
output "public_ip" {
  value = aws_instance.example.public_ip
}
