# Challenges and Resolutions

This document records the main technical issues encountered during implementation and how they were resolved.

---

## 1. GitHub Actions to AWS OIDC Authentication

### Problem

GitHub Actions initially failed while attempting to assume the AWS IAM deployment role.

### Cause

The GitHub OIDC subject differs between a normal branch workflow and a GitHub Environment workflow.

### Resolution

The IAM trust policy was updated to explicitly allow the required repository branch subject and the production environment subject.

### Result

GitHub Actions successfully authenticated to AWS without storing long-lived AWS access keys.

---

## 2. Dependency Vulnerability in Flask

### Problem

The dependency vulnerability scan reported a vulnerability in the initial Flask version.

### Resolution

The Flask dependency was updated to:

```text
Flask==3.1.3
```

## 3. Dependency Vulnerability in pytest

### Problem

A later dependency scan identified a vulnerability in the initial `pytest` version.

### Resolution

`pytest` was updated to:

```text
pytest==9.0.3
```

The pipeline dependency scan subsequently passed.

---

## 4. Container Base Image Vulnerabilities

### Problem

Initial Python base images produced vulnerability findings during Snyk container scanning.

### Resolution

The application was moved to:

```text
python:3.12-alpine
```

The resulting image was scanned using **Trivy** and **Snyk**.

The application dependencies had no vulnerable paths reported by the dependency scan, and the configured CI checks passed.

## 5. Semgrep Scanning Workflow Syntax

### Problem

The initial Semgrep configuration scanned repository content outside the application source and encountered GitHub Actions workflow expressions that were interpreted as shell/code syntax.

### Resolution

The Semgrep scan was scoped to:

```text
app/
```

The workflow and Terraform directories were excluded from the application SAST scan.

### Result

The local Semgrep scan reported:

```text
Findings: 0
```

## 6. Application Container Startup

### Problem

The ALB initially returned HTTP `502` responses because the application container was not yet available on port `5000`.

### Resolution

The EC2 deployment was configured to:

1. Install Docker
2. Pull the ECR image
3. Start the container
4. Expose port `5000`
5. Verify the application health endpoint

The ALB target group uses `/health` as its health check.

### Result

The ALB target became healthy and the application was reachable through the load balancer.
