8Byte DevOps & DevSecOps Assignment
 
 
 
 
 
An end-to-end DevOps and DevSecOps implementation on AWS covering infrastructure as code, secure CI/CD, container security, controlled deployment, monitoring, centralized logging, alerting, backups, and secret management.
The application itself is intentionally lightweight so the project can focus on the DevOps/DevSecOps lifecycle.
📌 What This Project Demonstrates
- Infrastructure provisioning with Terraform
- AWS networking with public and private subnets
- Dockerized Flask application on Amazon EC2
- Application Load Balancer with health checks
- Amazon RDS PostgreSQL in private subnets
- Container image management with Amazon ECR
- CI/CD with GitHub Actions
- Keyless AWS authentication using GitHub OIDC
- Remote deployment using AWS Systems Manager
- Automated testing and security gates
- CloudWatch dashboards, centralized logs, and alarms
- RDS automated backups
- Database credentials stored in AWS Secrets Manager
- Encrypted remote Terraform state in Amazon S3
🏗️ Architecture
 
End-to-end flow
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
EC2 + Docker + Gunicorn
    |
    v
Application Load Balancer
    |
    v
Flask Application
    |
    v
RDS PostgreSQL
☁️ AWS Infrastructure
Region
ap-south-1
VPC
10.0.0.0/16
Network layout
VPC
├── Public Subnet 1
│   └── ALB / EC2
├── Public Subnet 2
│   └── ALB
├── Private Subnet 1
│   └── RDS PostgreSQL
└── Private Subnet 2
    └── RDS PostgreSQL
Subnet CIDRs
Type	CIDR
Public subnet 1	10.0.1.0/24
Public subnet 2	10.0.2.0/24
Private subnet 1	10.0.11.0/24
Private subnet 2	10.0.12.0/24


The infrastructure uses an Internet Gateway for public connectivity.
Cost decision: A NAT Gateway was intentionally not used for this assignment environment.

🔐 Network Security
Traffic is restricted using separate security groups.
Internet
   |
   | TCP 80 / 443
   v
ALB
   |
   | TCP 5000
   v
EC2 Application
   |
   | TCP 5432
   v
RDS PostgreSQL
Security-group rules
Source	Destination	Port	Purpose
Internet	ALB	80/443	Application traffic
ALB Security Group	EC2 Security Group	5000	Application traffic
EC2 Security Group	RDS Security Group	5432	PostgreSQL


RDS is deployed without public accessibility.
🚀 CI/CD Pipeline
GitHub Actions automates testing, security validation, image publishing, and deployment.
Pull Request
Pull Request
     |
     +--> Unit Tests
     +--> Integration Tests
     +--> Semgrep
     +--> Gitleaks
     +--> pip-audit
     +--> Snyk
     +--> SonarCloud
     +--> Container Security Checks
Push to main
Push to main
     |
     v
Build & Security Checks
     |
     v
Amazon ECR
     |
     v
Staging Deployment
     |
     v
Manual Production Approval
     |
     v
Production Deployment
Security and quality tooling
Area	Tool
Unit testing	pytest
Integration testing	Docker + HTTP health check
SAST	Semgrep
Secret scanning	Gitleaks
Python dependency audit	pip-audit
Dependency security	Snyk
Code quality	SonarCloud
Container vulnerability scanning	Trivy
Container vulnerability scanning	Snyk


🔑 Secure AWS Authentication
GitHub Actions uses OpenID Connect (OIDC) to assume an AWS IAM role.
GitHub Actions
      |
      | OIDC
      v
AWS IAM Role
      |
      v
AWS Services
This removes the need for long-lived AWS access keys in the CI/CD workflow.
AWS Systems Manager is used for remote deployment to EC2 rather than requiring SSH-based deployment.
🐳 Containerization
The application is packaged as a Docker image.
Docker security characteristics
- Multi-stage Docker build
- Alpine-based runtime image
- Non-root application user
- Gunicorn production server
- Container vulnerability scanning
- No Flask development server in the production container
Application port
5000
Health endpoint
GET /health
Expected response:
{
  "status": "healthy"
}
📦 Amazon ECR
The Docker image is stored in Amazon ECR.
GitHub Actions
      |
      v
Docker Build
      |
      v
Security Scans
      |
      v
Amazon ECR
      |
      v
AWS Systems Manager
      |
      v
EC2 Docker Container
This provides a centralized image registry and separates image build/publish from deployment.
🖥️ Deployment
Deployment is performed through AWS Systems Manager.
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
Docker
      |
      v
Gunicorn
The application is exposed through the Application Load Balancer.
The ALB health-check endpoint is:
/health
📊 Monitoring
Two Amazon CloudWatch dashboards are configured.
1. 8Byte-Infrastructure
The infrastructure dashboard tracks:
- EC2 CPU utilization
- EC2 memory utilization
- EC2 disk utilization
- RDS CPU utilization
- RDS database connections
- RDS free storage
- System logs
Infrastructure dashboard
 
2. 8Byte-Application
The application dashboard tracks:
- Application request count
- HTTP 4xx errors
- HTTP 5xx errors
- Application latency
- Healthy targets
- Unhealthy targets
- Application logs
- ALB access logs
Application dashboard
 
🚨 CloudWatch Alarms
CloudWatch alarms are configured for operational monitoring.
Current alarms:
Alarm	Metric	Condition	Current state
EC2_Alarm	EC2 CPUUtilization	>= 80%	OK
RDS_CPU_Alarm	RDS CPUUtilization	>= 80%	OK


Alarm evidence
 
The alarms provide a starting point for infrastructure alerting and can be extended with application-specific thresholds as workload requirements increase.
📝 Centralized Logging
Logs are collected into CloudWatch Logs.
Application logs
/8byte-devops/application
Application logs include Docker/Gunicorn output and application traffic such as ALB health checks.
System logs
/8byte-devops/system
System logs include host-level events such as systemd, SSM, and audit-related events.
ALB access logs
/aws/vendedlogs/elasticloadbalancing/loadbalancer/ALB_ACCESS_LOGS/app
ALB access logs provide request-level information including:
- Request line
- User agent
- Request source
- Request timing
- Load balancer traffic information
🗄️ RDS PostgreSQL
RDS PostgreSQL is deployed in the private subnets.
EC2
 |
 | TCP 5432
 v
RDS PostgreSQL
Database protection
- Private subnet placement
- Security-group restricted access
- Encrypted storage
- Automated backups
- Credentials managed through AWS Secrets Manager
Backup
Automated backup retention: 1 day
🔐 Secrets Management
Database credentials are managed using AWS Secrets Manager.
Terraform
   |
   v
AWS Secrets Manager
   |
   v
Database credentials
Credentials are not intended to be stored directly in source control.
🏗️ Terraform
Terraform is used to provision and manage the AWS infrastructure.
Structure
terraform/
├── backend.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── main.tf
├── outputs.tf
├── modules/
│   ├── alb/
│   ├── ec2/
│   ├── rds/
│   ├── security-groups/
│   └── vpc/
└── environments/
Terraform modules
Module	Responsibility
vpc	VPC and subnet networking
security-groups	ALB, application, and database security groups
ec2	EC2 instance and SSM access
alb	Application Load Balancer and target group
rds	PostgreSQL database


Initialize and validate
cd terraform

terraform init
terraform validate
terraform plan
Terraform state is stored remotely in Amazon S3 with encryption and Terraform state locking.
🧪 Application Testing
Install dependencies
cd app

python -m pip install -r requirements.txt
Run tests
pytest -v
Build Docker image
From the repository root:
docker build -t 8byte-devops-app ./app
Run locally
docker run --rm -p 5000:5000 8byte-devops-app
Health check
curl http://localhost:5000/health
Expected:
{"status":"healthy"}
🛡️ Security Controls
AWS
- GitHub OIDC
- IAM permissions
- IMDSv2
- Private RDS
- Restricted security groups
- Encrypted Terraform state
- Encrypted RDS storage
- AWS Systems Manager
CI/CD
- Semgrep
- Gitleaks
- pip-audit
- Snyk
- SonarCloud
- Trivy
Container
- Non-root user
- Multi-stage build
- Minimal runtime image
- Gunicorn production server
- Container vulnerability scanning
💰 Cost Optimization
The assignment environment intentionally avoids unnecessary AWS costs.
Key decisions:
- t3.micro EC2
- Small RDS instance
- No NAT Gateway
- Limited monitoring scope
- Assignment-sized infrastructure
- Resources can be stopped when not required
For a production environment, sizing, availability, NAT requirements, retention, backup strategy, and alerting thresholds should be reviewed against actual workload requirements.
📁 Repository Structure
8byte-devops-assignment/
│
├── .github/
│   └── workflows/
│       └── ci.yml
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   └── tests/
│       └── test_app.py
│
├── terraform/
│   ├── backend.tf
│   ├── providers.tf
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── modules/
│   │   ├── alb/
│   │   ├── ec2/
│   │   ├── rds/
│   │   ├── security-groups/
│   │   └── vpc/
│   └── environments/
│
├── docs/
│   ├── approach.md
│   ├── challenges.md
│   └── screenshots/
│       ├── application-dashboard.png
│       ├── infrastructure-dashboard.png
│       └── cloudwatch-alarms.png
│
├── architecture/
│   └── 8byte-architecture-diagram.png
│
└── README.md
📚 Documentation
Document	Description
[`docs/approach.md`](docs/approach.md)	Implementation approach
[`docs/challenges.md`](docs/challenges.md)	Challenges and resolutions
[`architecture/8byte-architecture-diagram.png`](architecture/8byte-architecture-diagram.png)	AWS architecture diagram


🎯 Assignment Coverage
Requirement	Implementation
Infrastructure as Code	Terraform
AWS networking	VPC + public/private subnets
Compute	EC2 + Docker
Load balancing	Application Load Balancer
Database	RDS PostgreSQL
Container registry	Amazon ECR
CI/CD	GitHub Actions
AWS authentication	GitHub OIDC
Deployment	AWS Systems Manager
Testing	pytest + integration tests
SAST	Semgrep
Secret scanning	Gitleaks
Dependency scanning	pip-audit + Snyk
Container scanning	Trivy + Snyk
Code quality	SonarCloud
Monitoring	CloudWatch
Centralized logging	CloudWatch Logs
Alerting	CloudWatch Alarms
Secret management	AWS Secrets Manager
Database backup	RDS automated backups
Documentation	README + approach + challenges


🔗 Repository
GitHub:
https://github.com/akshigour12/8byte-devops-assignment
👩‍💻 Author
Akshita Gour
DevOps / DevSecOps Engineer
Focus areas:
AWS · Terraform · Docker · GitHub Actions · Linux · DevSecOps · CloudWatch · CI/CD
