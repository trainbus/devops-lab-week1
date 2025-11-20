
 Lab Week 1 – Infrastructure Progress Log

## ✅ Completed Milestones

- Initialized Terraform project structure with modular design
- Created shared VPC, subnets, and security groups
- Provisioned IAM role and instance profile for EC2 with SSM + ECR access
- Modularized EC2 provisioning across `web`, `api`, `ops`, `app`, and `wordpress`
- Injected `mongo_uri` via GitHub Secrets instead of AWS Secrets Manager
- Cleaned up duplicate variable declarations and unused outputs
- Validated Terraform configuration (`terraform validate`)
- Applied infrastructure successfully (`terraform apply`)
- Confirmed EC2 instance outputs:
  - App Public IP: `3.90.114.63`
  - Ops IP: `52.55.41.24`
  - Web IP: `98.89.23.133`
  - WordPress IP: `54.172.158.48`

## 🧠 Notes

- IAM instance profile was missing initially — resolved by applying `shared` module first
- `dev.tfvars` must be passed explicitly unless renamed to `terraform.tfvars`
- `mongo_uri` is now passed via `.tfvars` instead of Secrets Manager to save costs

## 📌 Next Steps

- SSH into EC2 and validate app deployment
- Add Route 53 DNS entries for public-facing services
- Bake AMIs for faster future deploys
- Push to GitHub and trigger CI/CD pipelineep 1: Create a CHANGELOG.md or infra-log.md


## ✅ EC2 Instance Live

- HAProxy and Nginx running successfully
- SSL configured and site reachable at https://onwuachi.com
- Docker not yet installed — next step for containerized apps
- Verified system health, uptime, and service status

## 🔧 Docker Group Membership

- Added `ubuntu` user to `docker` group via `usermod -aG docker ubuntu`
- Ensured Docker is installed before modifying group
- Note: user must log out and back in for group membership to apply

## 🐛 Fix: Invalid Cloud-init Structure

- Removed invalid nesting of `write_files` inside `runcmd`
- Refactored `web.yaml.tpl` to use proper top-level `write_files` block
- Ensured Docker Compose and HTML landing page are written correctly

## 🔧 Refactor: Cloud-init to Shell Script

- Converted cloud-init provisioning logic into `setup_web_stack.sh`
- Avoided YAML parse errors and improved reliability
- Modularized Docker install, ECR login, and container startup
