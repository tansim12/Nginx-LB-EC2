# Lab1-LB - Custom EC2-Based Load Balancer on AWS (Terraform)

Reusable, modular Terraform infrastructure for AWS that deploys a custom Nginx
load balancer (EC2) reverse-proxying to private Node.js application servers.
Supports dev / staging / production environments via Terraform Cloud workspaces.

Region: `ap-southeast-1` (Singapore)

## Architecture

```text
  Internet
    |
Internet Gateway (IGW)
    |
nginx-vpc  (Public EC2, Nginx reverse proxy)
  |-----------------------------|
  |                             |
node-app-1 (Private EC2)    node-app-2 (Private EC2)
  (port 3000)                 (port 3000)
```

- `nginx-vpc` sits in a **public subnet**, receives HTTP/HTTPS from the
  Internet via the IGW, and forwards traffic to the Node backends.
- `node-app-1` / `node-app-2` sit in **private subnets**, reachable only from
  the Nginx security group (port 3000). They reach the internet via a NAT
  Gateway.
- No AWS ALB/NLB is used — this is an educational custom EC2-based load
  balancer.

## Folder Structure

```
infra/
├── terraform.tf                  # Root provider config (no token)
├── bootstrap/main.tf             # Shared provider template
├── modules/                      # Reusable modules
│   ├── key-pair/                 # Register existing SSH public key
│   ├── vpc/                      # VPC
│   ├── subnet/                   # Public + private subnets (for_each)
│   ├── internet-gateway/         # IGW + attachment
│   ├── nat-gateway/              # EIP + NAT gateway (conditional)
│   ├── route-table/              # Public & private route tables
│   ├── security-group/           # Security groups (dynamic rules)
│   ├── ec2/                      # EC2 instances (for_each)
│   └── nginx/                    # Nginx config template renderer
├── templates/
│   └── nginx.conf.tftpl          # Nginx config with dynamic upstream
├── environments/
│   ├── dev/                      # dev workspace (lab1-lb-dev)
│   ├── staging/                  # staging workspace (lab1-lb-staging)
│   └── production/               # production workspace (lab1-lb-production)
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
├── .gitignore
└── README.md
```

## Security Rules (enforced)

- No AWS credentials hardcoded anywhere.
- No Terraform Cloud token in `.tf` files.
- Secrets never appear in outputs or logs.
- SSH access restricted to a configurable trusted CIDR.
- Node application port 3000 is **not** exposed publicly.
- Existing SSH public key `~/.ssh/my-key-pair.pub` is registered via
  `aws_key_pair` — no new key pair is generated.

## Prerequisites

1. Terraform CLI >= 1.5.0 installed.
2. AWS credentials configured locally (`~/.aws/credentials` or env vars).
3. Existing SSH public key at `~/.ssh/my-key-pair.pub`.
4. A valid Ubuntu AMI ID for `ap-southeast-1` set in each
   `environments/<env>/terraform.tfvars` (the placeholder `ami-0abcdef...`
   must be replaced).

   Lookup example:
   ```bash
   aws ec2 describe-images --region ap-southeast-1 \
     --owners 099720109477 \
     --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
     --query 'Images[*].{ID:ImageId,Name:Name,Date:CreationDate}' --output table
   ```

## Terraform Cloud (remote backend)

Each environment is a separate TFC workspace in the `Tansim` organization:

| Environment | Workspace |
|-------------|-----------|
| dev         | lab1-lb-dev |
| staging     | lab1-lb-staging |
| production  | lab1-lb-production |

Configure the token securely (never in `.tf`):

```bash
# Option A: environment variable
export TF_TOKEN_app_terraform_io=<YOUR_TFC_TOKEN>

# Option B: terraform login (writes to ~/.terraform.d/credentials.tfrc.json)
terraform login
```

Then work in an environment directory:

```bash
cd infra/environments/dev
terraform init      # selects the lab1-lb-dev workspace
terraform validate
terraform plan
# review the plan, then:
# terraform apply   # only with explicit approval
```

Repeat for `staging` and `production` with their respective tfvars.

## Deployment Workflow

### Phase 1 - Dev
```bash
cd infra/environments/dev
terraform init
terraform validate
terraform plan
terraform apply   # explicit approval
```

Verify:
- Nginx reachable: `curl http://<nginx_public_ip>`
- Traffic distributed across node-app-1 / node-app-2 (check `os.hostname()`).

### Phase 2 - Staging & Production
```bash
cd infra/environments/staging
terraform init && terraform plan && terraform apply

cd infra/environments/production
terraform init && terraform plan && terraform apply
```

Deploy dev first, verify, then promote to staging and production.

## Adding an Instance / Subnet

- Add another EC2: add an entry to the `instances` map in `environments/<env>/main.tf`
  (no new resource blocks needed — `for_each` handles it).
- Add another AZ/subnet: add an entry to `public_subnet_cidrs` and
  `private_subnet_cidrs` maps in `terraform.tfvars`.

## Outputs

Each environment outputs: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`,
`internet_gateway_id`, `nat_gateway_id`, `key_pair_name`,
`instance_private_ips`, `instance_public_ips`, `nginx_public_ip`,
`security_group_lb_id`, `security_group_node_id`, `nginx_config`.

## Validation

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
```

Review the plan before applying. `terraform apply` / `terraform destroy` are
never run automatically — explicit approval required.

## Production Readiness Checklist

- [ ] Replace placeholder AMI IDs with valid ap-southeast-1 AMIs
- [ ] Restrict `trusted_ssh_cidr` to corporate / VPN CIDR (not 0.0.0.0/0)
- [ ] Enable `deploy_nginx_config` only if SSH reachability is confirmed
- [ ] Configure Terraform Cloud token via env var or `terraform login`
- [ ] Create TFC workspaces (lab1-lb-dev/staging/production) before first run
- [ ] Enable termination protection on nginx instance (already set)
- [ ] Review `terraform plan` output before every apply
- [ ] Consider NAT Gateway HA (multiple AZs) for production
- [ ] Enable detailed CloudWatch monitoring (already set)
- [ ] Tag all resources consistently (done via `common_tags`)


## স্থাপত্যিক সিদ্ধান্তের ব্যাখ্যা (বাংলায়)

মূল স্থাপত্যিক সিদ্ধান্তগুলো নিচে বাংলায় ব্যাখ্যা করা হলো:

১. **কাস্টম EC2 ভিত্তিক লোড ব্যালেন্সার**: AWS ALB/NLB ব্যবহার না করে একটি EC2 ইনস্ট্যান্সে Nginx চালিয়ে রিভার্স প্রক্সি তৈরি করা হয়েছে। এটি শিক্ষামূলক এবং নোড সার্ভারগুলোর ট্রাফিক নিয়ন্ত্রণে সহায়ক।

২. **পাবলিক ও প্রাইভেট সাবনেট**: Nginx ইনস্ট্যান্সটি পাবলিক সাবনেটে থাকে যিটি ইন্টারনেট গেটওয়ের মাধ্যমে HTTP/HTTPS ট্রাফিক গ্রহণ করে। নোড অ্যাপ সার্ভারগুলো প্রাইভেট সাবনেটে থাকে, যা বাহ্যিকভাবে সরাসরি অ্যাক্সেসযোগ্য নয়।

৩. **ন্যাট গেটওয়ে**: প্রাইভেট সাবনেটের ইনস্ট্যান্সগুলো আউটবাউন্ড ইন্টারনেটের জন্য ন্যাট গেটওয়ের মাধ্যমে যাতায় করে। ডেভ family এ খরচ কমাতে একক ন্যাট গেটওয়ে ব্যবহার করা যেতে পারে।

৪. **সিকিউরিটি গ্রুপ**: নোড অ্যাপ পোর্ট ৩০০০ সাধারণভাবে খোলা নয়; শুধু Nginx সিকিউরিটি গ্রুপ থেকে ট্রাফিক গ্রহণযোগ্য। SSH কনফিগারড বিশ্বস্ত সিআইডিআর থেকে সীমাবদ্ধ।

৫. **টের্রাফর্ম ক্লাউড রিমোট স্টেট**: ডেভ, স্টেজিং, প্রোডাকশনের জন্য আলাদা ওয়ার্কস্পেস আছে যাতে স্টেট আইসোলেশন বজায় থাকে। টোকেন কোডে হার্ডকোড করা হয়নি।

৬. **ডাইনামিক রিসোর্স**: `for_each` এবং ভেরিয়েবল ম্যাপ ব্যবহার করে নতুন EC2 বা সাবনেট যোগ করতে কোড ডুপ্লিকেট করার প্রয়োজন হয় না।

