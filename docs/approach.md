# Implementation Approach

## 1. Infrastructure

Terraform is used to provision AWS infrastructure using reusable modules.

Main components:

- VPC
- Public and private subnets
- Security Groups
- EC2
- Application Load Balancer
- RDS PostgreSQL

---

## 2. Networking

The architecture uses:

- VPC: `10.0.0.0/16`
- 2 public subnets
- 2 private subnets
- Internet Gateway
- No NAT Gateway to reduce cost

Traffic flow:

```text
Internet
   |
   v
ALB
   |
   v
EC2
   |
   v
RDS
```
RDS is deployed in private subnets.

## 3. Terraform State

Terraform state is stored remotely in **Amazon S3**.

State protection includes:

- 🔐 Encryption
- 🗂️ Versioning
- 🚫 Public access blocking
- 🔒 Terraform state locking

---

## 4. Application

A lightweight **Flask application** is containerized using Docker.

The application provides the following endpoints:

| Endpoint | Purpose |
|---|---|
| `/` | Application root |
| `/health` | Application health check |

**Gunicorn** is used as the production application server.

The container runs as a **non-root user** for improved security.

---

## 5. CI/CD

**GitHub Actions** is used for the CI/CD pipeline.

The pipeline performs the following checks:

- 🧪 Unit testing
- 🔗 Integration testing
- 🔍 Semgrep
- 🔐 Gitleaks
- 📦 pip-audit
- 🛡️ Snyk
- 📊 SonarCloud
- 🐳 Trivy

Successful builds are pushed to **Amazon ECR**.

---

## 6. Deployment

**AWS Systems Manager (SSM)** is used for EC2 deployment instead of SSH.

### Deployment Flow

```text
GitHub Actions
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


## 7. AWS Authentication

GitHub Actions uses **AWS IAM OIDC**.

This avoids storing **long-lived AWS access keys** in GitHub.

---

## 8. Database & Secrets

**RDS PostgreSQL** is deployed in private subnets.

Database access is restricted to the **application security group**.

Security measures include:

- 🔐 Encrypted storage
- 💾 Automated backups
- 🔑 AWS Secrets Manager
- 🚫 Restricted port `5432`

---

## 9. Monitoring & Logging

**Amazon CloudWatch** is used for monitoring and logging.

### 📊 Monitoring Dashboards

Dashboards monitor:

- EC2 CPU, memory, and disk utilization
- RDS metrics
- ALB request count
- HTTP errors
- Application latency
- Target health

### 📝 Centralized Logging

Logs are centralized in the following CloudWatch log groups:

```text
/8byte-devops/application
/8byte-devops/system
```

## 10. Security & Cost
### 🔐 Security
Security is integrated throughout the implementation using:
- IAM
- OIDC
- Security Groups
- IMDSv2
- Private RDS
- AWS Secrets Manager
- Semgrep
- Gitleaks
- Snyk
- Trivy
### 💰 Cost Optimization
Cost is controlled using:
- t3.micro EC2 instance
- Small RDS instance
- No NAT Gateway
- Lightweight container
- Assignment-sized infrastructure
