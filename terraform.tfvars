# Configurações do Amazon MQ (RabbitMQ) - SINGLE INSTANCE (RÁPIDO)
aws_region           = "us-east-1"
broker_name          = "fiapx-rabbitmq-v6"
broker_instance_type = "mq.t3.micro"

# IDs da Infraestrutura
vpc_id         = "vpc-8ce247f1" 
subnet_id      = "subnet-c3f47da5" 
eks_node_sg_id = "sg-0a8d872ed21fea014" 
