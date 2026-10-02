Approach Documentation

1. Objective

The assignment was implemented as a small but production-oriented DevOps/DevSecOps workflow. The application logic was intentionally kept simple so that the main focus remained on infrastructure, automation, security, deployment, monitoring, and operational practices.

2. Infrastructure Approach

Terraform was selected for AWS infrastructure provisioning.

The infrastructure was divided into reusable modules:

VPC

Security Groups

EC2

RDS

ALB

The network uses:

One VPC

Two public subnets

Two private subnets

Internet Gateway

Public route table

The application EC2 instance is placed in a public subnet because the assignment uses a simple cost-controlled deployment without a NAT Gateway. The database is placed in private subnets and is not publicly accessible.

A NAT Gateway was intentionally avoided to control assignment cost.

3. State Management

Terraform state is stored remotely in an encrypted S3 bucket with versioning and public-access blocking.

The S3 backend uses Terraform's lockfile mechanism for state locking.

Terraform state files are excluded from Git.

4. Application and Container Approach

A lightweight Flask application provides:

/

/health

Gunicorn is used as the production application server.

The Docker image uses:

Python 3.12 Alpine

Multi-stage build

Non-root application user

Gunicorn

Port 5000

This keeps the image small and reduces unnecessary runtime privileges.

5. CI/CD Approach

GitHub Actions was selected for CI/CD.

The pipeline is divided into validation, security, build, registry, and deployment stages.

Pull Request / Validation

The workflow performs:

Unit tests

Integration tests

Semgrep SAST

Gitleaks secret scanning

pip-audit dependency scanning

Snyk dependency scanning

SonarCloud analysis

Docker build

Trivy container scanning

Snyk container scanning

Main Branch

After successful checks on main:

Docker image is tagged with the Git commit SHA.

Image is pushed to Amazon ECR.

Staging deployment is performed.

Application health is verified.

Production waits for manual approval.

Production deployment is performed.

Application health is verified again.

6. AWS Authentication

GitHub Actions uses AWS IAM OIDC.

This avoids storing long-lived AWS access keys in GitHub.

The IAM trust policy restricts the GitHub repository and permitted deployment contexts.

7. Deployment Approach

AWS Systems Manager is used instead of SSH.

The deployment process:

GitHub Actions
      |
      v
OIDC -> AWS
      |
      v
ECR Authentication
      |
      v
Pull Image on EC2
      |
      v
Replace Running Container
      |
      v
Health Check

A readiness loop was added so the pipeline waits for the application to become available instead of assuming the container is immediately ready.

8. Database Approach

Amazon RDS PostgreSQL is deployed in private subnets.

The database security group accepts port 5432 only from the application security group.

RDS storage is encrypted.

Automated backups are configured with one-day retention for the assignment.

Database credentials are generated with Terraform and stored in AWS Secrets Manager.

9. Monitoring Approach

CloudWatch is used for infrastructure and application observability.

Infrastructure

The CloudWatch Agent provides custom:

mem_used_percent

disk_used_percent

EC2 CPU and RDS metrics are provided through AWS service metrics.

Application

ALB metrics provide:

Request count

4xx responses

5xx responses

Latency

Healthy targets

Unhealthy targets

Logging

Application Docker logs are sent to:

/8byte-devops/application

System journal logs are exported and sent to:

/8byte-devops/system

10. Security Approach

Security was integrated into the pipeline rather than treated as a separate final step.

Controls include:

SAST

Secret scanning

Dependency scanning

Container scanning

Non-root containers

Restricted security groups

Private database

IAM/OIDC

IMDSv2

Encrypted storage

Secrets Manager

11. Cost Approach

The assignment environment was intentionally kept small.

Cost-control decisions included:

Small EC2 instance

Small RDS instance

No NAT Gateway

Lightweight Docker image

Limited CloudWatch metric collection

Minimal infrastructure required to demonstrate the requested architecture

12. Deployment Promotion

The current workflow uses a manual GitHub production approval after successful staging deployment.

For this assignment, the staging and production workflow stages use the same EC2 deployment target. The approval gate demonstrates controlled promotion without adding a second production infrastructure stack and its additional cost.

13. Result

The final implementation provides a reproducible infrastructure definition, automated DevSecOps pipeline, controlled deployment process, centralized monitoring/logging, database backup, and secret management.
