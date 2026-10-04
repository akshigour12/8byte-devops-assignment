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
```

### Request Flow

1. Users access the application through the **Application Load Balancer**.
2. The ALB forwards application traffic to the **EC2 instance** on TCP port `5000`.
3. The Flask application runs inside a **Docker container** using **Gunicorn**.
4. The application communicates with **RDS PostgreSQL** on TCP port `5432`.

---

## 🌐 AWS Network Layout

```text
AWS VPC - 10.0.0.0/16
│
├── Public Subnet 1 - 10.0.1.0/24
│   ├── Application Load Balancer
│   └── EC2 Application
│
├── Public Subnet 2 - 10.0.2.0/24
│   └── Application Load Balancer
│
├── Private Subnet 1 - 10.0.11.0/24
│   └── RDS PostgreSQL
│
└── Private Subnet 2 - 10.0.12.0/24
    └── RDS PostgreSQL
```

> 💰 **Cost Optimization:** A NAT Gateway was intentionally not used in this assignment environment to control cost.

---

## 🔄 CI/CD and Deployment Flow

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
```

### CI/CD Process

- Code is pushed to **GitHub**.
- **GitHub Actions** starts the CI/CD pipeline.
- Automated testing and security checks are executed.
- The Docker image is built and scanned.
- The validated image is pushed to **Amazon ECR**.
- **AWS Systems Manager** is used to deploy the image to EC2.
- The application runs inside Docker using **Gunicorn**.
