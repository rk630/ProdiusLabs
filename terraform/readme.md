### Step 3: Write Terraform Scripts

#### Create Terraform Directory Structure
Create a directory named `terraform` and inside it, create the following files: `main.tf`, `variables.tf`, and `outputs.tf`.

#### Define Variables (`variables.tf`)
```hcl
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
}

variable "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone"
}

variable "domain_name" {
  description = "The domain name for the web application"
}
```

#### AWS Provider Configuration (`main.tf`)
```hcl
provider "aws" {
  region = var.aws_region
}
```

#### Create S3 Bucket (`main.tf`)
```hcl
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
}
```

#### Create EC2 Instance with Docker Installed (`main.tf`)
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" // Amazon Linux 2 AMI
  instance_type = "t2.micro"
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install docker -y
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" > /home/ec2-user/.env
                echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /home/ec2-user/.env
                echo "S3_BUCKET_NAME=${S3_BUCKET_NAME}" >> /home/ec2-user/.env
                echo "AWS_REGION=${AWS_REGION}" >> /home/ec2-user/.env
                docker run -d -p 80:3000 --env-file /home/ec2-user/.env <your-dockerhub-username>/web-app:latest
              EOF
  tags = {
    Name = "WebAppInstance"
  }
}
```

#### Create CloudFront Distribution (`main.tf`)
```hcl
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_instance.web.public_dns
    origin_id   = "webAppOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for Web Application"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "webAppOrigin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
```

#### Auto-Scaling Configuration (`main.tf`)
```hcl
resource "aws_launch_configuration" "web_lc" {
  name          = "webAppLaunchConfiguration"
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install docker -y
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" > /home/ec2-user/.env
                echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> /home/ec2-user/.env
                echo "S3_BUCKET_NAME=${S3_BUCKET_NAME}" >> /home/ec2-user/.env
                echo "AWS_REGION=${AWS_REGION}" >> /home/ec2-user/.env
                docker run -d -p 80:3000 --env-file /home/ec2-user/.env <your-dockerhub-username>/web-app:latest
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg" {
  launch_configuration = aws_launch_configuration.web_lc.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = ["subnet-xxxxxx"]

  tag {
    key                 = "Name"
    value               = "WebAppInstance"
    propagate_at_launch = true
  }
}
```

#### Route 53 Configuration (`main.tf`)
```hcl
resource "aws_route53_record" "web" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution

.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
```

#### Outputs (`outputs.tf`)
```hcl
output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "route53_record" {
  value = aws_route53_record.web.name
}
```

### Step 4: Deploying with Terraform

1. Initialize Terraform:
    ```sh
    terraform init
    ```

2. Plan the deployment:
    ```sh
    terraform plan -var "s3_bucket_name=<your-s3-bucket-name>" -var "route53_zone_id=<your-route53-zone-id>" -var "domain_name=<your-domain-name>"
    ```

3. Apply the deployment:
    ```sh
    terraform apply -var "s3_bucket_name=<your-s3-bucket-name>" -var "route53_zone_id=<your-route53-zone-id>" -var "domain_name=<your-domain-name>"
    ```

### Testing the Application

After deploying, you can access the web application using the CloudFront distribution domain name or the domain name configured in Route 53. The application should be live, and you can test the file upload functionality to ensure files are uploaded to the S3 bucket.

### Documentation

#### README.md
```markdown
# Web Application Deployment with Terraform

## Overview
This project demonstrates the deployment of a web application using Docker and Terraform on AWS. The application handles file uploads to an S3 bucket, is fronted by a CloudFront CDN, and supports auto-scaling to manage varying workloads efficiently. Additionally, it uses Route 53 for domain name management.

## Structure
- `main.tf`: Main Terraform configuration file.
- `variables.tf`: Variable definitions.
- `outputs.tf`: Outputs for the Terraform deployment.
- `web`: Contains the Dockerized web application code.
- `README.md`: Documentation for the project.

## Prerequisites
- AWS account with IAM user having necessary permissions.
- Docker installed locally.
- Terraform installed locally.
- AWS CLI configured with necessary access keys.

## Steps to Deploy

1. **Prepare the Web Application:**
    - Create a directory for the web application.
    - Create and populate `index.html`, `server.js`, `Dockerfile`, and `package.json`.

2. **Build and Push Docker Image:**
    ```sh
    docker build -t web-app .
    docker tag web-app:latest <your-dockerhub-username>/web-app:latest
    docker push <your-dockerhub-username>/web-app:latest
    ```

3. **Create Terraform Scripts:**
    - Define variables in `variables.tf`.
    - Configure AWS provider and resources in `main.tf`.
    - Define outputs in `outputs.tf`.

4. **Deploy with Terraform:**
    ```sh
    terraform init
    terraform plan -var "s3_bucket_name=<your-s3-bucket-name>" -var "route53_zone_id=<your-route53-zone-id>" -var "domain_name=<your-domain-name>"
    terraform apply -var "s3_bucket_name=<your-s3-bucket-name>" -var "route53_zone_id=<your-route53-zone-id>" -var "domain_name=<your-domain-name>"
    ```

5. **Access the Application:**
    - Use the CloudFront distribution domain name or the configured domain name to access the web application.
    - Test the file upload functionality to ensure files are uploaded to the S3 bucket.
```
