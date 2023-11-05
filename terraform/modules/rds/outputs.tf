output "db_secret_arm" {
  value = aws_secretsmanager_secret.db.arn
}