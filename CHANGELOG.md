
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
