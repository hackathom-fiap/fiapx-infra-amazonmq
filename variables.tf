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
