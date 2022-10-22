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

resource "aws_instance" "k3s" {
  count         = 1
  ami           = data.aws_ami.bullseye.id
  instance_type = "t3.small"
  subnet_id     = module.vpc.public_subnets["10.0.0.0/24"].id

  user_data = module.cloud_init.rendered
  vpc_security_group_ids = [
    aws_security_group.in.id
  ]

  tags = {
    Name = "instance-${count.index}"
  }
}

output "instances" {
  value = aws_instance.k3s[*].public_ip
}

resource "aws_security_group" "in" {
  vpc_id = module.vpc.id
}

module "ingress_rules" {
  source = "github.com/invizus/terraform-aws-vpc/modules/sg_rule"
  type   = "ingress"
  ports = [
    22
  ]
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  id = aws_security_group.in.id
}

