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

Refer 
- [FE Source Code](src/readme.md)
- [Terraform Scripts](terraform/readme.md)    for detailed documentation.


    terraform apply -var "s3_bucket_name=<your-s3-bucket-name>" -var "route53_zone_id=<your-route53-zone-id>" -var "domain_name=<your-domain-name>"
    ```

5. **Access the Application:**
    - Use the CloudFront distribution domain name or the configured domain name to access the web application.
    - Test the file upload functionality to ensure files are uploaded to the S3 bucket.
