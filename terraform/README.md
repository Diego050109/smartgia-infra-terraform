# ✅ SMARTGIA - High Availability Infrastructure (Terraform + AWS)

This project deploys a high availability architecture on AWS using Terraform.

✅ Components included:

- VPC with public and private subnets
- Bastion Host (public EC2) with Elastic IP
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) in private subnets
- Launch Template with NGINX installed via `user_data`
- Security Groups (restricted access)

---

## ✅ Architecture

Internet → ALB → Auto Scaling Group (Private EC2 Instances)  
                  ↑  
              Bastion Host (SSH Access)

---

## ✅ How to Deploy

### 1️⃣ Initialize Terraform

```bash
terraform init
