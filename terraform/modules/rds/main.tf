resource "aws_db_subnet_group" "this" {
  name = "devops-${var.environment}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier = "devops-${var.environment}-postgres"

  engine         = "postgres"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  port = 5432

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]

  publicly_accessible = false

  backup_retention_period = 1
  backup_window           = "18:00-18:30"

  maintenance_window = "sun:19:00-sun:19:30"

  skip_final_snapshot = true
  deletion_protection = false

  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-${var.environment}-postgres"
  }
}
