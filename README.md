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

  ## ☁️ AWS Infrastructure

| **Component** | **Configuration** |
|---|---|
| **AWS Region** | `ap-south-1` |
| **VPC CIDR** | `10.0.0.0/16` |
| **Public Subnets** | 2 |
| **Private Subnets** | 2 |
| **Internet Gateway** | Yes |
| **NAT Gateway** | No |
| **Compute** | EC2 `t3.micro` |
| **Load Balancer** | Application Load Balancer (ALB) |
| **Database** | Amazon RDS PostgreSQL |
| **Container Registry** | Amazon ECR |
| **Remote Management** | AWS Systems Manager (SSM) |
| **Monitoring** | Amazon CloudWatch |

## 🌐 Subnet Configuration

| **Subnet** | **CIDR** | **Purpose** |
|---|---|---|
| **Public Subnet 1** | `10.0.1.0/24` | ALB + EC2 |
| **Public Subnet 2** | `10.0.2.0/24` | ALB |
| **Private Subnet 1** | `10.0.11.0/24` | RDS |
| **Private Subnet 2** | `10.0.12.0/24` | RDS |

# 🔐 Network Security

Traffic is restricted using separate **Security Groups** following a least-privilege approach.

```text
Internet
   |
   | TCP 80 / 443
   v
ALB Security Group
   |
   | TCP 5000
   v
EC2 Application Security Group
   |
   | TCP 5432
   v
RDS Security Group

| **Source** | **Destination** | **Port** | **Purpose** |
|---|---|---:|---|
| Internet | ALB Security Group | `80/443` | Application traffic |
| ALB Security Group | EC2 Security Group | `5000` | Application traffic |
| EC2 Security Group | RDS Security Group | `5432` | PostgreSQL database traffic |


#🔑 Secure AWS Authentication

GitHub Actions authenticates to AWS using **OpenID Connect (OIDC)**, eliminating the need to store long-lived AWS access keys in GitHub Secrets.

```text
GitHub Actions
      |
      | OIDC
      v
AWS IAM Role
      |
      v
AWS Services

🔐 Authentication Flow
1. GitHub Actions starts the CI/CD workflow.
2. GitHub issues a short-lived OIDC identity token.
3. AWS IAM validates the token using the configured GitHub OIDC provider.
4. GitHub Actions assumes the designated IAM Role.
5. Temporary AWS credentials are provided to the workflow.
6. The workflow uses these credentials to access the required AWS services.
Security Benefit: No long-lived AWS access keys or secret access keys are stored in the CI/CD workflow.

🚀 EC2 Deployment
AWS Systems Manager (SSM) is used for EC2 deployment instead of traditional SSH-based deployment.
GitHub Actions
      |
      | AWS IAM + OIDC
      v
AWS Systems Manager
      |
      | Run Command
      v
EC2 Instance
