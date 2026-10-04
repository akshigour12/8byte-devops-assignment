# 8Byte DevOps & DevSecOps Assignment

An end-to-end **DevOps and DevSecOps implementation on AWS** using Terraform, GitHub Actions, Docker, Amazon ECR, EC2, Application Load Balancer, RDS PostgreSQL, AWS Systems Manager, and CloudWatch.

The application is intentionally lightweight so the project focuses on the **infrastructure, CI/CD, security, deployment, monitoring, logging, and operational practices** expected in a DevOps/DevSecOps environment.

---

## 📌 Project Highlights

- Infrastructure as Code with **Terraform**
- AWS VPC with **public and private subnets**
- Dockerized Flask application running on **EC2**
- **Application Load Balancer** with health checks
- **RDS PostgreSQL** deployed in private subnets
- Docker images stored in **Amazon ECR**
- CI/CD using **GitHub Actions**
- Keyless AWS authentication using **GitHub OIDC**
- Remote deployment using **AWS Systems Manager**
- Automated unit and integration testing
- SAST, secret, dependency, code-quality, and container scanning
- **CloudWatch dashboards, centralized logging, and alarms**
- RDS automated backups
- Database credentials managed with **AWS Secrets Manager**
- Remote and encrypted Terraform state in **Amazon S3**

---

# 🏗️ Architecture

![8Byte AWS Architecture](architecture/8byte-architecture-diagram.png)

The solution is designed around a secure AWS architecture with a public-facing Application Load Balancer, containerized application running on EC2, and a PostgreSQL database hosted in private subnets.

---

## 📐 Application Flow

```text
Internet
   |
   v
Application Load Balancer
   |
   | TCP 5000
   v
EC2 + Docker + Gunicorn
   |
   | TCP 5432
   v
RDS PostgreSQL
