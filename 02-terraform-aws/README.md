# Terraform AWS Example

This project demonstrates a basic **Infrastructure‑as‑Code** setup for the DevOps Junior portfolio.

## Overview
- **VPC** with a public subnet
- **EC2** instance (Ubuntu) with a security group allowing SSH (port 22) and HTTP (port 80)
- **RDS** (MySQL) instance (free‑tier) within the VPC
- Outputs for VPC ID, EC2 public IP, and RDS endpoint

## Prerequisites
- Terraform ≥ 1.5
- AWS credentials configured (`aws configure`)
- An AWS account (free tier is sufficient)

## Usage
```bash
cd 02-terraform-aws
terraform init
terraform plan   # review resources
terraform apply   # confirm with "yes"
```
After `apply`, the output will display the resources IDs and connection details.

## Cleanup
```bash
terraform destroy   # confirm with "yes"
```

## Structure
- `main.tf` – core resources
- `variables.tf` – configurable inputs (region, instance type, etc.)
- `outputs.tf` – exported values

---
*Feel free to customize the instance type, AMI, or add more resources (e.g., S3 bucket, IAM role) to enrich the portfolio.*
