module "cloud_init" {
  source = "../modules/cloud_init"
}

module "vpc" {
  source     = "github.com/invizus/terraform-aws-vpc"
  cidr_block = "10.0.0.0/16"
  public_subnets = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
  private_subnets = [
    "10.0.3.0/24"
  ]
  tags = {
    Environment = "Development"
  }
}

data "aws_ami" "bullseye" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["debian-11-amd64*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "main" {
  vpc_id = module.vpc.id
}

resource "aws_security_group_rule" "in" {
  type              = "ingress"
  #for_each          = { for port in var.ports : port => port }
  for_each          = toset([
    "22",
  ])
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "out" {
  type              = "egress"
  #for_each          = { for port in var.ports : port => port }
  for_each          = toset([
    "80",
    "443",
  ])
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = [
    "0.0.0.0/0",
  ]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "self_tcp" {
  type              = each.key
  #for_each          = { for port in var.ports : port => port }
  for_each          = toset([
    "ingress",
    "egress",
  ])
  from_port         = 1
  to_port           = 65535
  protocol          = "tcp"
  self = true
  security_group_id = aws_security_group.main.id
}
########### puppet master

resource "aws_instance" "main" {
  ami           = data.aws_ami.bullseye.id
#  ami = "ami-01b8d743224353ffe"
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnets["10.0.0.0/24"].id

  user_data = module.cloud_init.rendered
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  tags = {
    Name = "puppet-main"
  }
}

output "master" {
  value = aws_instance.main.public_ip
}

############# puppet agent
resource "aws_instance" "agent1" {
  ami           = data.aws_ami.bullseye.id
#  ami = "ami-01b8d743224353ffe"
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnets["10.0.0.0/24"].id

  user_data = module.cloud_init.rendered
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  tags = {
    Name = "puppet-agent1"
  }
}


output "agent" {
  value = aws_instance.agent1.public_ip
}
