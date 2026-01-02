# devops-lab-admin-ui

Admin UI (React / Vite) for DevOps Lab.

## Build & run locally
- `npm install`
- `npm run build`
- `docker build -t devops-lab-admin-ui:local .`
- `docker run -p 8080:80 devops-lab-admin-ui:local`

## CI/CD
- GitHub Actions builds and pushes image to ECR repo specified via repository secrets:
  - `AWS_ACCOUNT_ID`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ECR_REPO_ADMIN` (set `devops-lab-admin-ui`)



# devops-lab-hugo

Hugo site image for DevOps Lab.

## Build & run locally
- `docker build -t devops-lab-hugo:local .`
- `docker run -p 1313:1313 devops-lab-hugo:local`

## CI/CD
- GitHub Actions builds and pushes to ECR:
  - Secrets required: `AWS_ACCOUNT_ID`, `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `ECR_REPO_HUGO` (set `devops-lab-hugo`)
