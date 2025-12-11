packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "source_ami" {
  type    = string
  default = "ami-04a81a99f5ec58529"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ami_name" {
  type    = string
  default = "admin-ui-ami-{{timestamp}}"
}

source "amazon-ebs" "admin_ui" {
  region                        = var.aws_region
  instance_type                 = var.instance_type
  source_ami                    = var.source_ami
  ssh_username                  = var.ssh_username
  ami_name                      = var.ami_name
  associate_public_ip_address   = true
}

build {
  name    = "admin-ui-image"
  sources = ["source.amazon-ebs.admin_ui"]

  # Install dependencies (nginx, docker if needed)
  provisioner "shell" {
    script = "scripts/install_deps.sh"
  }

  # Create directory on the instance for admin-ui static files
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /var/www/admin",
      "sudo chown ubuntu:ubuntu /var/www/admin"
    ]
  }

  # Upload the built Vite dist directory
  provisioner "file" {
    source      = "provision/admin-ui/dist/"
    destination = "/var/www/admin"
  }

  # Correct ownership
  provisioner "shell" {
    inline = [
      "sudo chown -R www-data:www-data /var/www/admin"
    ]
  }
}
-------------------



===================

Perfect — **you are thinking in the right direction now.**
Your architecture is already half-containerized (Node API), but the Admin UI + Hugo are still baked into AMIs → that’s why nothing is listening on the backend ports that HAProxy expects.

### ✅ YES — the cleanest, least-confusing, future-proof approach is:

# **Option A — Containerize ALL apps (Node API, Admin UI, Hugo)**

And create **new, clean repos** for the Admin UI + Hugo.

---

# ✅ HERE IS THE FULL FIX PLAN (STEP-BY-STEP)

I’ll lay this out cleanly so we don’t get lost.
We’ll do it **one app at a time**, and we won’t break anything.

---

# **1️⃣ Create new GitHub repos**

### ✔ Admin UI repo

Recommended name:
`admin-ui-app`

### ✔ Hugo site repo

Recommended name:
`hugo-site-app`

Each repo will get:

* a Dockerfile
* GitHub Action CI workflow
* ECR integration
* Terraform variables
* cloud-init runtime pull scripts

---

# **2️⃣ Create Dockerfiles (I’ll generate them)**

## ✔ Admin UI (Vite) — Dockerfile

```Dockerfile
# Stage 1 — Build
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2 — Serve static files
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## ✔ Hugo site — Dockerfile

```Dockerfile
FROM klakegg/hugo:0.123.7-alpine AS build
WORKDIR /src
COPY . .
RUN hugo --minify

FROM nginx:alpine
COPY --from=build /src/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

# **3️⃣ Create ECR repos**

You already have some old weird names (`devops-lab-app`, `devops-lab-app-02`) — let’s make new ones.

### New repos:

```
admin-ui
hugo-site
```

Command:

```
aws ecr create-repository --repository-name admin-ui
aws ecr create-repository --repository-name hugo-site
```

---

# **4️⃣ Add CI/CD Workflows (I will generate them)**

These mimic your Node API workflow.

## ✔ `.github/workflows/ci-admin-ui.yml`

```yaml
name: Admin UI CI/CD

on:
  push:
    branches: ["prod"]
    paths: ["**"]
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Login to ECR
        uses: aws-actions/amazon-ecr-login@v1

      - name: Set IMAGE_TAG
        run: echo "IMAGE_TAG=admin-$(date +'%Y%m%d-%H%M%S')" >> $GITHUB_ENV

      - name: Build & Push
        run: |
          REPO=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/admin-ui
          docker build -t $REPO:$IMAGE_TAG .
          docker tag $REPO:$IMAGE_TAG $REPO:latest
          docker push $REPO:$IMAGE_TAG
          docker push $REPO:latest
```

---

## ✔ `.github/workflows/ci-hugo.yml`

```yaml
name: Hugo Site CI/CD

on:
  push:
    branches: ["prod"]
    paths: ["**"]
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_SECRET }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Login to ECR
        uses: aws-actions/amazon-ecr-login@v1

      - name: Set IMAGE_TAG
        run: echo "IMAGE_TAG=hugo-$(date +'%Y%m%d-%H%M%S')" >> $GITHUB_ENV

      - name: Build & Push
        run: |
          REPO=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/hugo-site
          docker build -t $REPO:$IMAGE_TAG .
          docker tag $REPO:$IMAGE_TAG $REPO:latest
          docker push $REPO:$IMAGE_TAG
          docker push $REPO:latest
```

---

# **5️⃣ Update Terraform + cloud-init**

You will use the SAME pattern as the Node API:

### ✔ Admin UI cloud-init:

```
docker pull <admin-ui ecr>:latest
docker run -d -p 8080:80 admin-ui:latest
```

### ✔ Hugo cloud-init:

```
docker pull <hugo-site ecr>:latest
docker run -d -p 80:80 hugo-site:latest
```

---

# **6️⃣ Update HAProxy**

Your current HAProxy expects:

```
backend_admin  → 10.50.2.137:8080
backend_api    → 10.50.1.78:3000
backend_hugo   → 10.50.3.100:80
```

Containers must listen on those ports.

---

# **7️⃣ Clean up your old AMI builds**

Packer is no longer needed for:

* node api
* admin ui
* hugo

(only for the ops box / HAProxy)

---

# **8️⃣ I can now generate:**

### ✔ Full “How Everything Works” architecture document

### ✔ Fully-cleaned README.md for the entire project

### ✔ Diagrams

### ✔ Final code push plan

### ✔ Fix HAProxy defaults

### ✔ Fix missing ECR images

### ✔ Validate the entire pipeline

---

# ❓ Before I generate everything:

### **Do you want to proceed with Option A (ALL containerized)?**

**YES / NO?**

If yes →
I will generate:

🔥 3 repos
🔥 3 Dockerfiles
🔥 3 CI/CD pipelines
🔥 3 Terraform updates
🔥 cloud-init
🔥 HAProxy final config
🔥 Architecture diagram
🔥 Master README.md

Just say:

➡️ **“Yes, Option A — build everything.”**

======================================


