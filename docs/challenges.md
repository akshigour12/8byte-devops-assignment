Challenges and Resolutions

This document records the main technical issues encountered during implementation and how they were resolved.

1. GitHub Actions to AWS OIDC Authentication

Problem

GitHub Actions initially failed while attempting to assume the AWS IAM deployment role.

Cause

The GitHub OIDC subject differs between a normal branch workflow and a GitHub Environment workflow.

Resolution

The IAM trust policy was updated to explicitly allow the required repository branch subject and the production environment subject.

Result

GitHub Actions successfully authenticated to AWS without storing long-lived AWS access keys.

2. Dependency Vulnerability in Flask

Problem

The dependency vulnerability scan reported a vulnerability in the initial Flask version.

Resolution

The Flask dependency was updated to:

Flask==3.1.3

The dependency scan was rerun successfully.

3. Dependency Vulnerability in pytest

Problem

A later dependency scan identified a vulnerability in the initial pytest version.

Resolution

pytest was updated to:

pytest==9.0.3

The pipeline dependency scan subsequently passed.

4. Container Base Image Vulnerabilities

Problem

Initial Python base images produced vulnerability findings during Snyk container scanning.

Resolution

The application was moved to:

python:3.12-alpine

The resulting image was scanned using Trivy and Snyk.

The application dependencies had no vulnerable paths reported by the dependency scan, and the configured CI checks passed.

5. Semgrep Scanning Workflow Syntax

Problem

The initial Semgrep configuration scanned repository content outside the application source and encountered GitHub Actions workflow expressions that were interpreted as shell/code syntax.

Resolution

The Semgrep scan was scoped to:

app/

and the workflow and Terraform directories were excluded from the application SAST scan.

Result

The local Semgrep scan reported:

Findings: 0

6. Production Deployment Health Check Race

Problem

The production deployment initially failed because the immediate health check received:

curl: (56) Recv failure: Connection reset by peer

The container itself was healthy shortly afterward.

Cause

The deployment health check ran before Gunicorn had completely finished starting.

Resolution

A readiness loop was added to the staging and production deployment jobs.

The workflow now checks the health endpoint repeatedly before failing the deployment.

Result

The subsequent deployment completed successfully.

7. CloudWatch Agent Permissions

Problem

The CloudWatch Agent was installed and configured, but custom memory and disk metrics were not initially visible.

Cause

The EC2 IAM role did not initially have the required CloudWatch and CloudWatch Logs permissions.

Resolution

Permissions were added to the EC2 role for:

cloudwatch:PutMetricData

CloudWatch Logs group/stream creation

CloudWatch Logs event publishing

Result

Custom metrics appeared under:

8Byte/EC2

8. System Log Path on Amazon Linux

Problem

The expected /var/log/messages file was not present on the Amazon Linux instance.

Resolution

The systemd journal was used as the source of system logs.

A small systemd service exports journal entries to:

/var/log/8byte-system.log

The CloudWatch Agent then collects that file.

Result

System logs are available in:

/8byte-devops/system

with events from systemd, audit, and SSM Agent.

9. CloudWatch Agent Configuration Recreation

Problem

After using fetch-config, the original CloudWatch Agent JSON path was no longer available at the expected location.

Resolution

The complete CloudWatch Agent configuration was recreated and loaded using the supported fetch-config process.

Result

Configuration validation succeeded and both application and system log collection continued to work.

10. Remote Terraform State

Problem

Terraform state needed to be kept outside the Git repository and protected from concurrent state modifications.

Resolution

An encrypted, versioned S3 backend was configured with Terraform's S3 lockfile mechanism.

Result

terraform init and subsequent Terraform operations work with remote state.

11. Application Container Startup

Problem

The ALB initially returned HTTP 502 responses because the application container was not yet available on port 5000.

Resolution

The EC2 deployment was configured to:

Install Docker

Pull the ECR image

Start the container

Expose port 5000

Verify the application health endpoint

The ALB target group uses /health as its health check.

Result

The ALB target became healthy and the application was reachable through the load balancer.
