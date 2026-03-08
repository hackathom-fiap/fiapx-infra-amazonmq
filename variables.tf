variable "aws_region" {
  description = "Região da AWS para provisionar os recursos."
  type        = string
  default     = "us-east-1"
}

variable "broker_name" {
  description = "Nome do broker Amazon MQ."
  type        = string
  default     = "fiapx-rabbitmq"
}

variable "broker_instance_type" {
  description = "Tipo de instância para o broker."
  type        = string
  default     = "mq.t3.micro"
}

variable "vpc_id" {
  description = "O ID da VPC onde o broker será implantado."
  type        = string
}

variable "subnet_id" {
  description = "O ID da sub-rede PRIVADA para o broker (Single Instance)."
  type        = string
}

variable "eks_node_sg_id" {
  description = "O ID do Security Group dos nós do EKS para permitir acesso ao MQ."
  type        = string
}
