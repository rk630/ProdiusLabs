resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" // Amazon Linux 2 AMI
  instance_type = "t2.micro"
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install docker -y
                sudo service docker start
                sudo usermod -a -G docker ubuntu
                echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" > /home/ubuntu/.env
                echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /home/ubuntu/.env
                echo "S3_BUCKET_NAME=${S3_BUCKET_NAME}" >> /home/ubuntu/.env
                echo "AWS_REGION=${AWS_REGION}" >> /home/ubuntu/.env
                docker run -d -p 80:3000 --env-file /home/ubuntu/.env <your-dockerhub-username>/web-app:latest
              EOF
  tags = {
    Name = "WebAppInstance"
  }
}
