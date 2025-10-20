terraform {
  backend "s3" {
    bucket  = "devops-lab-tfstate-bucket" # must be globally unique
    key     = "devops-lab-week1/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

