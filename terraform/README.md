# 🚀 SMARTGIA - High Availability Infrastructure with Terraform

This project deploys a **high availability AWS infrastructure** using **Terraform**, including:

✅ VPC with Public & Private Subnets (2 AZ)  
✅ Internet Gateway + NAT Gateway  
✅ Bastion Host (SSH access)  
✅ Application Load Balancer (ALB)  
✅ Auto Scaling Group (ASG) with Launch Template  
✅ Private EC2 instances running NGINX  

---

## 🏗️ Architecture Overview

- **Public Subnets**
  - Bastion Host (SSH access)
  - ALB (HTTP access)

- **Private Subnets**
  - Auto Scaling Group instances
  - Instances are only reachable via ALB or Bastion

---

## ✅ Infrastructure Components

| Component | Description |
|----------|-------------|
| VPC | Private network for the infrastructure |
| Public Subnets | Hosts ALB and Bastion |
| Private Subnets | Hosts EC2 instances in ASG |
| NAT Gateway | Allows outbound internet access for private instances |
| Bastion Host | Secure SSH access to private instances |
| ALB | Distributes traffic across instances |
| ASG | Ensures high availability and scaling |
| Launch Template | Defines how ASG instances are created |

---

## ⚙️ Requirements

- AWS CLI configured (`aws configure`)
- Terraform installed
- Valid AWS credentials (AWS Academy / VocLabs supported)

---

## 🚀 How to Deploy

### 1️⃣ Initialize Terraform
```bash
terraform init
