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

### CI/CD and Deployment Flow

```text
Developer
   |
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Unit Tests
   +--> Integration Tests
   +--> Semgrep
   +--> Gitleaks
   +--> pip-audit
   +--> Snyk
   +--> SonarCloud
   +--> Trivy
   |
   v
Amazon ECR
   |
   v
AWS Systems Manager
   |
   v
EC2
   |
   v
Docker + Gunicorn
📐 Architecture
Application Flow
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
AWS Network Layout
AWS VPC - 10.0.0.0/16
|
+-- Public Subnet 1 - 10.0.1.0/24
|   +-- Application Load Balancer
|   +-- EC2 Application
|
+-- Public Subnet 2 - 10.0.2.0/24
|   +-- Application Load Balancer
|
+-- Private Subnet 1 - 10.0.11.0/24
|   +-- RDS PostgreSQL
|
+-- Private Subnet 2 - 10.0.12.0/24
    +-- RDS PostgreSQL
Cost Optimization: A NAT Gateway was intentionally not used in this assignment environment to control cost.
