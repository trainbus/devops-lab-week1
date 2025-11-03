resource "aws_secretsmanager_secret" "mongodb" {
  name        = "${var.project_name}-mongodb-uri"
  description = "MongoDB Atlas connection string"
}

resource "aws_secretsmanager_secret" "adsense" {
  name        = "${var.project_name}-adsense-key"
  description = "AdSense API key"
}

output "mongodb_secret_arn" {
  value = aws_secretsmanager_secret.mongodb.arn
}

output "adsense_secret_arn" {
  value = aws_secretsmanager_secret.adsense.arn
}
