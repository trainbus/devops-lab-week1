CloudOps Lab – Immutable Edge + Container Runtime Platform

A production-style, immutable infrastructure platform built with:

Packer (AMI baking)

Terraform (Infrastructure as Code)

HAProxy (Edge reverse proxy)

Docker (Application runtime)

Let’s Encrypt (Automated TLS)

AWS SSM Parameter Store (AMI version tracking)

Amazon ECR (Container registry)

This repository demonstrates a phased DevOps architecture focused on:

Immutability

Operational correctness

Clean separation of concerns

Safe production patterns

🎯 Platform Goals

Build hardened, repeatable AMIs

Separate build-time and run-time logic

Terminate TLS at the edge

Run applications as containers behind HAProxy

Eliminate manual server mutation

Enable controlled phased evolution

🧱 Current Architecture (Phase 2)
                Internet
                    │
                    ▼
              Route53 (DNS)
                    │
               Elastic IP
                    │
              EC2 (Ops Node)
                    │
                HAProxy
             (TLS Termination)
                    │
          ┌────────────────────┐
          │ 127.0.0.1:3000     │ → Platform API (Docker)
          │ 127.0.0.1:8080     │ → Hugo (nginx container)
          └────────────────────┘
Public Exposure

Ports: 80, 443 only

Containers bound to localhost

No direct backend exposure

📦 Phase Breakdown
✅ Phase 1 – Infrastructure Foundation

Packer-built Ubuntu 22.04 AMI

HAProxy installed and validated at build time

Dummy certificate baked to pass config validation

Let’s Encrypt issued at first boot

Certbot auto-renewal with HAProxy reload hook

Deterministic 503 response

Tag:

phase-1-infra-stable
✅ Phase 2 – Containerized Application Runtime (Current)

Phase 2 transitions from static infrastructure to application runtime.

Additions

Docker installed in AMI

systemd-managed containers

Platform API container (Node.js)

Hugo static site served via nginx container

Health checks (/ready)

HAProxy backend routing

ECR authentication via IAM role

Immutable AMI updates via SSM parameter

Runtime Model

systemd
→ docker pull
→ docker run
→ health check
→ HAProxy reverse proxy

All container images are pulled at runtime.
No application artifacts are baked into the AMI.

🔐 TLS Strategy
Stage	Certificate	Purpose
AMI Build	Dummy self-signed	Validate HAProxy config
First Boot	Let’s Encrypt	Real domain cert
Renewal	systemd timer + deploy hook	Auto rebuild PEM + reload HAProxy

Certbot runs twice daily via:

certbot.timer

Renewal hook:

/etc/letsencrypt/renewal-hooks/deploy/haproxy

This:

Rebuilds PEM bundle

Applies correct permissions

Reloads HAProxy

Avoids downtime

🏗 Immutable AMI Lifecycle

Packer builds hardened image

AMI ID stored in SSM:

/devopslab/ami/ops/latest

Terraform reads SSM parameter

terraform apply replaces EC2 if AMI changes

Instance boots cleanly

No in-place mutation.

🚀 Deployment Flow
Infrastructure
packer build
↓
AMI ID → SSM
↓
terraform apply
↓
EC2 replacement (if AMI changed)
Application
CI builds container
↓
Push to ECR
↓
Instance pulls image at service start
↓
systemd manages lifecycle
🛠 Repository Structure
infra/
├── packer/
│   └── ops/
│       ├── template.pkr.hcl
│       └── scripts/
│
├── terraform/
│   └── ops/
│
opt/
└── scripts/
    └── hugo.sh
🧪 Validation
curl -Iv https://onwuachi.com

Expected:

Valid Let's Encrypt certificate

200 or backend response

No direct container exposure

🧠 Design Principles

Infra before apps

Immutable > mutable

Containers are disposable

Edge terminates TLS

Health checks everywhere

Minimal public attack surface

Phase isolation

⚠️ Known Limitations (Intentional)

No centralized logging

No metrics aggregation

No autoscaling

Single-node runtime

No blue/green deployment

No alerting

These are addressed in Phase 3.

🔜 Phase 3 – Observability & Cost Control (Planned)

Prometheus

Grafana

Node exporter

HAProxy metrics

CloudWatch alarms

Cost allocation tagging

Budget alerts

📌 Status

Current Phase: 2 – Containerized Runtime Stable

Branch:

phase-2-app-backends

Upcoming tag:

phase-2-infra-stable
👤 Author

Derrick C. Onwuachi
Cloud / DevOps Engineer

This repository reflects a structured, production-minded infrastructure evolution.
