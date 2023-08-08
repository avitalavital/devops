# Configure the AWS provider
provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "terraform_key_pair" {
  key_name   = "terraform_key_pair"
  public_key = file("~/.ssh/terraform_key_pair.pub")
}

resource "aws_security_group" "terraform" {
  name        = "terraform-security-group"
  description = "terraform security group created by Terraform"

  # Inbound rules
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# Define the EC2 instance resource
resource "aws_instance" "test" {
  ami           = "ami-040d60c831d02d41c"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.terraform.id]
  key_name      = "terraform_key_pair"

  # Connection details for the remote-exec provisioner
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform_key_pair")
    host        = self.public_ip
  }

  # Run commands to install and start Nginx on the instance (Amazon Linux 2)
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user",
      "sudo docker run -d -p 5000:5000 avital1093/flask_project",
    ]
  }

  tags = {
    Name        = "test"
    Environment = "test"
    Project     = "terra-Project"
  }

  lifecycle {
    create_before_destroy = true
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
  vpc_security_group_ids = [aws_security_group.terraform.id]
  key_name      = "terraform_key_pair"

  # Connection details for the remote-exec provisioner
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/terraform_key_pair")
    host        = self.public_ip
  }

  # Run commands to install and start Nginx on the instance (Amazon Linux 2)
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ec2-user",
      "sudo docker run -d -p 5000:5000 avital1093/flask_project",

    ]
  }

  tags = {
    Name        = "prod"
    Environment = "prod"
    Project     = "terra-Project"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Output the public IP address of the created EC2 instance
output "public_ip_prod" {
  value = aws_instance.prod.public_ip
}

# Create a local file to write both public and private IP addresses
resource "local_file" "ip_addresses_file" {
  filename = "ip_addresses.txt"
  content  = <<-EOT
    Public IP: ${aws_instance.test.public_ip}
    Private IP: ${aws_instance.prod.public_ip}
  EOT
}
