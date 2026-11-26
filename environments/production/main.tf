terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Terraform Cloud remote backend - production workspace.
  # Configure the token via: export TF_TOKEN_app_terraform_io=<TOKEN>
  # or run: terraform login
  cloud {
    organization = "Tansim"
    workspaces {
      name = "lab1-lb-production"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.common_tags
  }
}

locals {
  public_subnet_id      = module.subnet.public_subnet_id_list[0]
  private_subnet_ids    = module.subnet.private_subnet_id_list
  first_private_subnet  = module.subnet.private_subnet_id_list[0]
  second_private_subnet = length(module.subnet.private_subnet_id_list) > 1 ? module.subnet.private_subnet_id_list[1] : module.subnet.private_subnet_id_list[0]

  nginx_user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    EOF

  node_user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nodejs npm
    mkdir -p /app
    cat > /app/server.js <<'NODEEOF'
    const http = require('http');
    const os = require('os');
    const server = http.createServer((req, res) => {
      res.writeHead(200, { 'Content-Type': 'text/plain' });
      res.end('Hello from ' + os.hostname() + '\\n');
    });
    server.listen(3000, () => console.log('Node app listening on 3000'));
    NODEEOF
    nohup node /app/server.js > /app/app.log 2>&1 &
    EOF
}

module "key_pair" {
  source = "../../modules/key-pair"

  key_name        = var.key_name
  public_key_path = var.public_key_path
}

module "vpc" {
  source = "../../modules/vpc"

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  environment          = var.environment
  name                 = var.name_prefix
  common_tags          = var.common_tags
}

module "subnet" {
  source = "../../modules/subnet"

  vpc_id                  = module.vpc.vpc_id
  environment             = var.environment
  name                    = var.name_prefix
  common_tags             = var.common_tags
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  create_private_subnets  = var.create_private_subnets
  map_public_ip_on_launch = true
}

module "internet_gateway" {
  source = "../../modules/internet-gateway"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  name        = var.name_prefix
  common_tags = var.common_tags
}

module "nat_gateway" {
  source = "../../modules/nat-gateway"

  vpc_id             = module.vpc.vpc_id
  public_subnet_id   = module.subnet.public_subnet_id_list[0]
  enable_nat_gateway = var.enable_nat_gateway
  environment        = var.environment
  name               = var.name_prefix
  common_tags        = var.common_tags
}

module "route_table" {
  source = "../../modules/route-table"

  vpc_id             = module.vpc.vpc_id
  igw_id             = module.internet_gateway.igw_id
  nat_gateway_id     = module.nat_gateway.nat_gateway_id
  enable_nat_gateway = module.nat_gateway.nat_gateway_enabled
  public_subnet_ids  = module.subnet.public_subnet_id_list
  private_subnet_ids = module.subnet.private_subnet_id_list
  environment        = var.environment
  name               = var.name_prefix
  common_tags        = var.common_tags
}

module "security_group_lb" {
  source = "../../modules/security-group"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  name        = "${var.name_prefix}-lb"
  description = "Nginx load balancer security group"
  common_tags = var.common_tags

  ingress_cidr = [
    {
      description = "Allow HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTPS from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow SSH from trusted CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.trusted_ssh_cidr]
    }
  ]
  ingress_sg = []
  egress_cidr = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "security_group_node" {
  source = "../../modules/security-group"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
  name        = "${var.name_prefix}-node"
  description = "Node application security group"
  common_tags = var.common_tags

  ingress_cidr = [
    {
      description = "Allow SSH from trusted CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.trusted_ssh_cidr]
    }
  ]

  ingress_sg = [
    {
      description              = "Allow Node app traffic from Nginx LB"
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      source_security_group_id = module.security_group_lb.id
    }
  ]

  egress_cidr = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "ec2" {
  source = "../../modules/ec2"

  environment = var.environment
  common_tags = var.common_tags
  key_name    = var.key_name

  instances = {
    nginx-vpc = {
      role                   = "nginx"
      instance_type          = var.nginx_instance_type
      ami                    = var.ami
      subnet_id              = module.subnet.public_subnet_id_list[0]
      security_group_ids     = [module.security_group_lb.id]
      user_data              = local.nginx_user_data
      termination_protection = true
      monitoring             = true
    }
    node-app-1 = {
      role                   = "node-app"
      instance_type          = var.node_instance_type
      ami                    = var.ami
      subnet_id              = local.first_private_subnet
      security_group_ids     = [module.security_group_node.id]
      user_data              = local.node_user_data
      termination_protection = false
      monitoring             = true
    }
    node-app-2 = {
      role                   = "node-app"
      instance_type          = var.node_instance_type
      ami                    = var.ami
      subnet_id              = local.second_private_subnet
      security_group_ids     = [module.security_group_node.id]
      user_data              = local.node_user_data
      termination_protection = false
      monitoring             = true
    }
  }
}

module "nginx" {
  source = "../../modules/nginx"

  template_path      = "${path.root}/templates/nginx.conf.tftpl"
  upstream_name      = "node_backend"
  upstream_algorithm = var.lb_algorithm
  listen_port        = 80
  upstream_servers = [
    {
      name = "node-app-1"
      ip   = module.ec2.private_ips["node-app-1"]
      port = 3000
    },
    {
      name = "node-app-2"
      ip   = module.ec2.private_ips["node-app-2"]
      port = 3000
    }
  ]
}

resource "local_file" "nginx_config" {
  content  = module.nginx.nginx_config
  filename = "${path.module}/rendered-nginx.conf"
}

resource "null_resource" "deploy_nginx_config" {
  count = var.deploy_nginx_config ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      scp -o StrictHostKeyChecking=no -i ${var.public_key_path} ${path.module}/rendered-nginx.conf ${var.ssh_user}@${module.ec2.public_ips["nginx-vpc"]}:/tmp/nginx.conf
      ssh -o StrictHostKeyChecking=no -i ${var.public_key_path} ${var.ssh_user}@${module.ec2.public_ips["nginx-vpc"]} 'sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf && sudo nginx -t && sudo systemctl reload nginx'
    EOT
  }

  depends_on = [
    module.ec2,
    local_file.nginx_config
  ]
}
