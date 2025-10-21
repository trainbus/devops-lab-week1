# 🌍 Onwuachi.com Web Server (HAProxy + Nginx + SSL)

This Terraform module provisions a secure Ubuntu-based web server for **onwuachi.com**.  
It installs and configures **HAProxy**, **Nginx**, and **Certbot** for free SSL via Let's Encrypt.

---

## ⚙️ Infrastructure Overview

| Component | Description |
|------------|-------------|
| **EC2 Instance** | Ubuntu 22.04 (t3.micro) web host |
| **HAProxy** | Acts as reverse proxy and SSL termination point |
| **Nginx** | Serves static content on port 8080 |
| **Certbot** | Automates SSL certificate generation/renewal |
| **AWS CLI** | Used for potential automation or updates |

---

## 🧩 Prerequisites

- A valid AWS account
- A **Namecheap domain** (onwuachi.com) with DNS **A record** pointing to this EC2 instance’s public IP
- Existing AWS key pair (referenced via `var.key_name`)

---

## 🚀 Deployment Steps

1. Initialize Terraform:

   ```bash
   terraform init

