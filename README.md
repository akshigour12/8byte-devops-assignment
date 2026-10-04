8Byte DevOps & DevSecOps Assignment
An end-to-end DevOps and DevSecOps implementation on AWS using Terraform, GitHub Actions, Docker, Amazon ECR, EC2, Application Load Balancer, RDS PostgreSQL, AWS Systems Manager, AWS Secrets Manager, and Amazon CloudWatch.
The project covers infrastructure as code, secure CI/CD, container security, controlled deployment, monitoring, centralized logging, alarms, backup, and operational documentation.
---
📌 Project Highlights
Infrastructure provisioned using Terraform
AWS VPC with 2 public + 2 private subnets
Dockerized Flask application running on EC2
Application Load Balancer for application traffic
RDS PostgreSQL deployed in private subnets
Docker images stored in Amazon ECR
GitHub Actions CI/CD pipeline
GitHub Actions → AWS authentication through OIDC
Automated unit and integration testing
SAST, secret, dependency, code-quality, and container scanning
Staging deployment followed by manual production approval
AWS Systems Manager used for deployment without SSH access
CloudWatch dashboards, centralized logs, and alarms
RDS automated backups
Database credentials managed with AWS Secrets Manager
Terraform remote state stored in encrypted Amazon S3
---
🏗️ Architecture
![8Byte DevOps & DevSecOps Architecture](architecture/8byte-architecture-diagram.png)
Deployment flow
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
EC2 + Docker + Gunicorn
    |
    v
Application Load Balancer
    |
    v
Flask Application
```
AWS network flow
```text
                         Internet
                            |
                         :80/:443
                            |
                            v
                  +-------------------+
                  | Application Load  |
                  |    Balancer       |
                  +-------------------+
                            |
                          :5000
                            |
                            v
              +-------------------------+
              | Public Subnet           |
              | EC2 + Docker + Gunicorn |
              +-------------------------+
                            |
                          :5432
                            |
                            v
              +-------------------------+
              | Private Subnet          |
              | RDS PostgreSQL          |
              +-------------------------+
```
---
☁️ AWS Infrastructure
Region
```text
ap-south-1
```
VPC
```text
10.0.0.0/16
```
Subnets
```text
Public:
  10.0.1.0/24
  10.0.2.0/24

Private:
  10.0.11.0/24
  10.0.12.0/24
```
Main AWS components
Component	Purpose
VPC	Network isolation
Public Subnets	ALB and EC2
Private Subnets	RDS PostgreSQL
Internet Gateway	Internet connectivity for public resources
EC2	Application host
Docker	Application container
ALB	Traffic distribution and health checks
RDS PostgreSQL	Relational database
ECR	Container image registry
Systems Manager	Remote deployment/management
CloudWatch	Monitoring, dashboards, logs and alarms
Secrets Manager	Database credential storage
S3	Terraform remote state
> A NAT Gateway was intentionally not used to control assignment cost.
---
🔐 Security Group Flow
```text
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
```
Security groups restrict traffic so that:
Internet → ALB: `80/443`
ALB → EC2: `5000`
EC2 → RDS: `5432`
RDS is not publicly accessible
---
🚀 CI/CD Pipeline
GitHub Actions performs automated validation and security checks.
```text
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
```
Security checks
Check	Tool
Unit testing	pytest
Integration testing	Docker + curl
SAST	Semgrep
Secret scanning	Gitleaks
Python dependency scan	pip-audit
Dependency security	Snyk
Code quality	SonarCloud
Container security	Trivy
Container security	Snyk Container
---
🔑 AWS Authentication
GitHub Actions uses:
```text
GitHub OIDC
     |
     v
AWS IAM Role
     |
     v
AWS Services
```
This avoids storing long-lived AWS access keys in GitHub Actions.
AWS Systems Manager is used to deploy the container to EC2, avoiding the need to expose SSH access for the deployment workflow.
---
🐳 Docker
The application image uses:
Multi-stage Docker build
Python Alpine runtime
Gunicorn
Non-root application user
Container vulnerability scanning
Application port:
```text
5000
```
Health endpoint:
```text
GET /health
```
Expected response:
```json
{
  "status": "healthy"
}
```
---
📊 CloudWatch Monitoring
Two CloudWatch dashboards are configured.
8Byte-Infrastructure
The infrastructure dashboard contains:
EC2 CPU utilization
EC2 memory utilization
EC2 disk utilization
RDS CPU utilization
RDS database connections
RDS free storage
System logs
Infrastructure Dashboard
![8Byte Infrastructure Dashboard](docs/screenshots/infrastructure-dashboard.png)
---
8Byte-Application
The application dashboard contains:
Application request count
Application 4xx errors
Application 5xx errors
Application latency
Healthy target monitoring
Unhealthy target monitoring
Application logs
ALB access logs
Application Dashboard
![8Byte Application Dashboard](docs/screenshots/application-dashboard.png)
---
📝 Centralized Logging
Application and system logs are centralized in CloudWatch.
Application logs
```text
/8byte-devops/application
```
These include Docker/Gunicorn application output and ALB health-check requests reaching the application.
System logs
```text
/8byte-devops/system
```
These include systemd, SSM, audit, and other host-level events collected from the EC2 instance.
ALB access logs
```text
/aws/vendedlogs/elasticloadbalancing/loadbalancer/ALB_ACCESS_LOGS/app
```
ALB access logs provide request-level information such as:
Request line
User agent
Request source
Request timing
ALB traffic information
---
🚨 CloudWatch Alarms
CloudWatch alarms are configured for infrastructure monitoring.
Current alarms include:
`EC2_Alarm`
`RDS_CPU_Alarm`
Both are shown in an OK state in the captured monitoring view.
Alarm Dashboard
![CloudWatch Alarms](docs/screenshots/cloudwatch-alarms.png)
---
🗄️ Database & Backup
RDS PostgreSQL is deployed inside the private subnets.
Security:
```text
EC2 Security Group
        |
        | TCP 5432
        v
RDS Security Group
```
RDS automated backups are enabled with:
```text
Retention: 1 day
```
Database credentials are managed using AWS Secrets Manager rather than being committed to source control.
---
🏗️ Terraform Structure
```text
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
```
Terraform state is stored remotely in Amazon S3 with encryption and state locking.
Initialize Terraform
```bash
cd terraform

terraform init
terraform validate
terraform plan
```
---
🧪 Application Testing
```bash
cd app

python -m pip install -r requirements.txt
pytest -v
```
Docker test
From the repository root:
```bash
docker build -t 8byte-devops-app ./app
docker run --rm -p 5000:5000 8byte-devops-app
```
Test:
```bash
curl http://localhost:5000/health
```
---
📁 Repository Structure
```text
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
```
---
🔒 Security Controls
AWS / Infrastructure
IAM least-privilege-oriented permissions
GitHub OIDC
IMDSv2
Private RDS
Restricted security groups
Encrypted Terraform state
Encrypted RDS storage
AWS Systems Manager for remote management
CI/CD
Semgrep SAST
Gitleaks secret scanning
pip-audit dependency scanning
Snyk dependency scanning
SonarCloud analysis
Trivy container scanning
Snyk container scanning
Container
Non-root user
Multi-stage build
Minimal runtime image
Gunicorn production server
---
💰 Cost Optimization
The assignment environment intentionally avoids unnecessary AWS costs.
Examples:
`t3.micro` EC2
Small RDS instance
No NAT Gateway
Limited CloudWatch monitoring scope
Assignment-focused infrastructure sizing
For a real production workload, sizing, high availability, NAT requirements, retention periods, and backup strategy should be reviewed according to workload requirements.
---
📚 Documentation
Additional project documentation:
`docs/approach.md` — implementation approach
`docs/challenges.md` — challenges and resolutions
`architecture/8byte-architecture-diagram.png` — architecture diagram
---
🔗 Repository
GitHub Repository
https://github.com/akshigour12/8byte-devops-assignment
---
🎯 Assignment Deliverables
Requirement	Implementation
Infrastructure as Code	Terraform
AWS Networking	VPC + public/private subnets
Compute	EC2 + Docker
Load Balancing	Application Load Balancer
Database	RDS PostgreSQL
CI/CD	GitHub Actions
Container Registry	Amazon ECR
Deployment	AWS Systems Manager
AWS Authentication	GitHub OIDC
Testing	pytest + integration tests
SAST	Semgrep
Secret Scanning	Gitleaks
Dependency Scanning	pip-audit + Snyk
Container Scanning	Trivy + Snyk
Code Quality	SonarCloud
Monitoring	CloudWatch
Logging	CloudWatch Logs
Alerting	CloudWatch Alarms
Secrets	AWS Secrets Manager
Backup	RDS automated backups
Documentation	README + approach + challenges
