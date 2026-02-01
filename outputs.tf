output "broker_id" {
  description = "O ID do broker Amazon MQ."
  value       = aws_mq_broker.rabbitmq.id
}

output "broker_endpoint" {
  description = "O endpoint principal do broker."
  value       = aws_mq_broker.rabbitmq.instances[0].endpoints[0]
}

output "mq_password_secret_arn" {
  description = "O ARN do segredo no Secrets Manager contendo a senha do usuário do MQ."
  value       = aws_secretsmanager_secret.mq_password.arn
}
