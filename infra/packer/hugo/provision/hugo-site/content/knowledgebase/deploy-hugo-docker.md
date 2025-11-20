---
title: "Deploy Hugo with Docker Compose"
date: 2025-10-16T10:00:00Z
tags: ["hugo", "docker", "ci/cd"]
category: "Infrastructure"
language: "bash"
params:
  github_link: "https://github.com/demystifying-dev/docker-compose-hugo-app-builder"
---

To run Hugo as a containerized service with hot reloading for local development, use this minimal Docker Compose config:

```yaml
services:
  hugo:
    image: hugomods/hugo:exts-non-root
    command: server -D --bind=0.0.0.0
    volumes:
      - ./:/src
      - ~/hugo_cache:/tmp/hugo_cache
    ports:
      - "1313:1313"


---

### Sales/Ads (AdSense + Mock Products)

#### content/sales/_index.md

```markdown
---
title: "Storefront & Ads"
date: 2025-11-05T13:00:00Z
description: "Browse mock product listings and observe ad spots, including native Google AdSense integration."
---

Welcome to our **mock storefront**! Below are example products (not for sale), and sample ads powered by [Google AdSense](https://www.google.com/adsense).

---

#### Mock Product Listings

| Product              | Description                | Price    |
|----------------------|----------------------------|----------|
| CloudNinja T-shirt   | 100% cotton, ninja logo.   | $19.99   |
| DevOps Mug           | Holds coffee _and_ secrets | $14.99   |
| Vinyl Sticker Set    | Set of 5, waterproof.      | $6.99    |
| Tech Memes Poster    | 11x17", limited edition.   | $9.99    |

*Note: These items are fictional for demo.*

---

#### Ad Block

Below is a real Google AdSense ad placeholder—replace `ca-pub-...` with your AdSense client ID:

{{< adsense-client >}}

