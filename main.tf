# Gera uma senha aleatória para o usuário do RabbitMQ
resource "random_password" "mq_password" {
  length           = 16
  special          = true
  override_special = "!@#$&*()_+-=[]{}|'"
}

# Armazena a senha gerada no AWS Secrets Manager
resource "aws_secretsmanager_secret" "mq_password" {
  name = "${var.broker_name}-password"
}

resource "aws_secretsmanager_secret_version" "mq_password" {
  secret_id     = aws_secretsmanager_secret.mq_password.id
  secret_string = random_password.mq_password.result
}

# Cria o broker Amazon MQ para RabbitMQ
resource "aws_mq_broker" "rabbitmq" {
  broker_name        = var.broker_name
  engine_type        = "RabbitMQ"

  host_instance_type = var.broker_instance_type
  deployment_mode    = "SINGLE_INSTANCE"
  publicly_accessible = true # Necessário para que a aplicação possa se conectar

  user {
    username = "user" # Mantendo o usuário 'user' como na config da app
    password = random_password.mq_password.result
  }

  # É crucial configurar um security group que permita acesso
  # à porta 5671 (AMQPS) a partir das suas aplicações.
  # Por simplicidade, estamos usando o security group default da VPC.
  # Em produção, um security group específico deve ser criado e referenciado.
  # security_groups = [aws_security_group.mq_sg.id]

  # Configuração de logs para CloudWatch
  logs {
    general = true
  }
}
