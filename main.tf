# Gera uma senha aleatória para o usuário do RabbitMQ
resource "random_password" "mq_password" {
  length           = 16
  special          = true
  override_special = "!@#$&*()_+-=[]{}|'"
}

# Armazena a senha gerada no AWS Secrets Manager
resource "aws_secretsmanager_secret" "mq_password" {
  name = "${var.broker_name}-password-v2" # Changed secret name to avoid conflict
}


resource "aws_secretsmanager_secret_version" "mq_password" {
  secret_id     = aws_secretsmanager_secret.mq_password.id
  secret_string = random_password.mq_password.result
}

# Busca os outputs do estado do Terraform do EKS
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "meu-eks-terraform-state"
    key    = "soat-tech-challenge/hackathon-eks.tfstate"
    region = var.aws_region
  }
}

# Obtém dados do security group dos nós do EKS para descobrir a VPC ID
data "aws_security_group" "eks_node_sg_data" {
  id = data.terraform_remote_state.eks.outputs.node_security_group_id
}

# Cria um security group específico para o Amazon MQ
resource "aws_security_group" "mq_sg" {
  name        = "${var.broker_name}-sg"
  description = "Security group para o broker Amazon MQ"
  vpc_id      = data.aws_security_group.eks_node_sg_data.vpc_id

  tags = {
    Name = "${var.broker_name}-sg"
  }
}

# Regra para permitir acesso dos nós do EKS ao broker na porta AMQPS
resource "aws_security_group_rule" "eks_to_mq" {
  type              = "ingress"
  from_port         = 5671
  to_port           = 5671
  protocol          = "tcp"
  security_group_id = aws_security_group.mq_sg.id
  source_security_group_id = data.terraform_remote_state.eks.outputs.node_security_group_id
}

# Cria o broker Amazon MQ para RabbitMQ
resource "aws_mq_broker" "rabbitmq" {
  broker_name                = var.broker_name
  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  auto_minor_version_upgrade = true
  host_instance_type         = var.broker_instance_type
  deployment_mode            = "SINGLE_INSTANCE"
  publicly_accessible        = false # Alterado para false para permitir security_groups

  user {
    username = "user"
    password = random_password.mq_password.result
  }

  # Associa o broker ao security group criado
  security_groups = [aws_security_group.mq_sg.id]

  # Configuração de logs para CloudWatch
  logs {
    general = true
  }
}
