# Gera uma senha aleatória para o usuário do RabbitMQ
resource "random_password" "mq_password" {
  length           = 17
  special          = true
  override_special = "!@#$%&*-+"
}

# Armazena a senha gerada no AWS Secrets Manager
resource "aws_secretsmanager_secret" "mq_password" {
  name = "${var.broker_name}-password-v6" # Incrementando versão para evitar conflitos
}

resource "aws_secretsmanager_secret_version" "mq_password" {
  secret_id     = aws_secretsmanager_secret.mq_password.id
  secret_string = random_password.mq_password.result
}

# Cria um security group específico para o Amazon MQ
resource "aws_security_group" "mq_sg" {
  name        = "${var.broker_name}-sg"
  description = "Security group para o broker Amazon MQ"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.broker_name}-sg"
  }
}

# Regra para permitir acesso dos nós do EKS ao broker na porta AMQP (5672) e AMQPS (5671)
resource "aws_security_group_rule" "eks_to_mq_5671" {
  type              = "ingress"
  from_port         = 5671
  to_port           = 5671
  protocol          = "tcp"
  security_group_id = aws_security_group.mq_sg.id
  source_security_group_id = var.eks_node_sg_id
}

resource "aws_security_group_rule" "eks_to_mq_5672" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  security_group_id = aws_security_group.mq_sg.id
  source_security_group_id = var.eks_node_sg_id
}

# Cria o broker Amazon MQ para RabbitMQ (MODO RÁPIDO - SINGLE INSTANCE)
resource "aws_mq_broker" "rabbitmq" {
  broker_name                = var.broker_name
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  auto_minor_version_upgrade = true
  host_instance_type         = var.broker_instance_type
  deployment_mode            = "SINGLE_INSTANCE" # Mudado para Instância Única (Mais rápido)
  publicly_accessible        = false 

  user {
    username = "appuser"
    password = random_password.mq_password.result
  }

  # Colocando o broker na subnet privada selecionada
  subnet_ids = [var.subnet_id]

  # Associa o broker ao security group criado
  security_groups = [aws_security_group.mq_sg.id]

  # Configuração de logs para CloudWatch
  logs {
    general = true
  }
}
