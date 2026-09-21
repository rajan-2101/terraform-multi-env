data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }
}

locals {
  tags = {
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_security_group" "web" {
  name   = "web-${var.environment}"
  vpc_id = data.aws_vpc.default.id
  tags   = local.tags

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = data.aws_ami.linux.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[count.index % length(data.aws_subnets.default.ids)]
  vpc_security_group_ids = [aws_security_group.web.id]
  tags                   = merge(local.tags, { Name = "web-${var.environment}-${count.index + 1}" })
}

output "instance_ids" {
  value = aws_instance.web[*].id
}
