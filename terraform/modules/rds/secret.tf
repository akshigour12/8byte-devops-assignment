resource "random_password" "db" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}-${var.environment}-rds-credentials"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    db_name  = var.db_name
  })
}
