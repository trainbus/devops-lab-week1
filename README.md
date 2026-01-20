# CloudOps Lab – Immutable Infrastructure Platform

A production‑style, immutable infrastructure platform built with **Packer**, **Terraform**, **HAProxy**, and **Let’s Encrypt**.

This repository documents a real‑world DevOps workflow focused on **correctness, repeatability, and operational safety** before application complexity.

---

## 🎯 Project Goals

* Build **immutable AMIs** with Packer
* Separate **build‑time** vs **run‑time** responsibilities
* Terminate TLS correctly using Let’s Encrypt
* Use HAProxy as a stable edge layer
* Bootstrap infrastructure without coupling to application state
* Enable clean, phased expansion (apps come *after* infra is solid)

---

## 🧱 Architecture Overview

```
Internet
   │
   ▼
Route53 (DNS)
   │
Elastic IP
   │
HAProxy (TLS termination)
   │
┌───────────────┐
│ Placeholder   │  → HTTP 503 (Phase 1)
│ Backend       │
└───────────────┘
```

> Application backends (Hugo, Admin UI, API) are intentionally **not enabled yet**.

---

## 📦 Phase Breakdown

### ✅ Phase 1 – Infrastructure Foundation (Current)

* Packer‑built Ubuntu 22.04 AMI
* HAProxy installed and validated at build time
* Dummy TLS certificate baked into AMI (build‑safe)
* Let’s Encrypt certificate issued at **first boot**
* HAProxy reloads with real certificate
* Deterministic `503 Service Unavailable` response

This phase proves:

* TLS works
* HAProxy works
* Cert lifecycle works
* Infra boots cleanly every time

---

### 🔜 Phase 2 – Application Backends (Planned)

* Hugo static site container
* Admin UI container
* API container
* HAProxy backend routing
* Zero‑downtime reloads

---

## 🛠️ Repository Structure

```
infra/
├── packer/
│   └── ops/
│       ├── template.pkr.hcl
│       └── scripts/
│           ├── install_base.sh
│           ├── install_haproxy.sh
│           ├── install_certbot.sh
│           ├── install_dummy_cert.sh
│           ├── install_renew_hook.sh
│           └── enable_services.sh
│
├── terraform/
│   └── ops/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
opt/
└── scripts/
    └── hugo.sh
```

---

## 🔐 TLS Strategy (Important)

| Stage      | Certificate       | Reason                       |
| ---------- | ----------------- | ---------------------------- |
| AMI build  | Dummy self‑signed | HAProxy must validate config |
| First boot | Let’s Encrypt     | Real cert, correct domain    |
| Renewal    | Deploy hook       | Zero‑downtime reload         |

This avoids:

* Broken AMI builds
* Runtime race conditions
* TLS failures during provisioning

---

## 🚀 Deployment Flow

1. **Build AMI** with Packer
2. Store AMI ID in SSM Parameter Store
3. Terraform reads latest AMI
4. EC2 instance launches
5. User‑data:

   * Issues cert (if missing)
   * Concatenates PEM
   * Reloads HAProxy
6. HTTPS is live

---

## 🧪 Validation

```bash
curl -Iv https://onwuachi.com
```

Expected:

* Valid Let’s Encrypt certificate
* HTTP `503 Service Unavailable`

This is **intentional** until Phase 2.

---

## 🧠 Design Principles

* **Infra before apps**
* **Fail safe, not fast**
* **Immutable > mutable**
* **One concern per phase**
* **Boring is good**

---

## 📌 Status

**Phase:** 1 – Infrastructure Stable

Tagged release:

```
phase-1-infra-stable
```

---

## 👤 Author

**Derrick C. Onwuachi**
DevOps / Cloud Operations Engineer

---

> This project is intentionally built as a learning and demonstration platform. Each phase is merged only when stable and reviewable.

