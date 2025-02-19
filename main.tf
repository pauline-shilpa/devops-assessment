# AWS provider
provider "aws" {
  region = "us-east-1"  
}

# Security Group for HTTP (80) and SSH (22)
resource "aws_security_group" "web_sg" {
  name        = "web_server_sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro"  
  security_groups = [aws_security_group.web_sg.name]
  key_name      = "your-key-pair"  

  # Install Apache Web Server 
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo "<h1> Hello, World! </h1>" | sudo tee /var/www/html/index.html
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  tags = {
    Name = "Terraform-WebServer"
  }
}

# Output the Public IP of the EC2 Instance
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}
