# Terraform Azure CI/CD with GitHub Actions

Complete CI/CD pipeline to deploy Terraform templates to Azure with:
- 🔍 Security scanning (Checkov)
- 📋 Terraform plan posted as a PR comment
- ✋ Manual approval gate before apply
- 🚀 Terraform apply on approval

---

## Pipeline Flow

```
Pull Request opened
        │
        ▼
┌─────────────────┐
│  Job 1: Scan    │  Checkov scans Terraform files for misconfigurations
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│  Job 2: Plan        │  az login → create backend → tf init → tf fmt
│                     │  → tf validate → tf plan → post plan to PR
└────────┬────────────┘
         │
         │  PR comment shows plan output
         │  Team reviews → merges PR
         │
         ▼  (push to main triggers apply job)
┌──────────────────────────┐
│  ✋ Manual Approval Gate  │  GitHub Environment "production" reviewer approves
└────────┬─────────────────┘
         │
         ▼
┌─────────────────────┐
│  Job 3: Apply       │  az login → tf init → download plan → tf apply
└─────────────────────┘
```

---

## Setup Steps

### Step 1 — Create Azure Service Principal

```bash
az ad sp create-for-rbac \
  --name "sp-github-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/<SUBSCRIPTION_ID>" \
  --sdk-auth
```

Copy the JSON output — you'll need it for secrets.

---

### Step 2 — Create Terraform Backend Storage

Run once before the pipeline:

```bash
chmod +x scripts/setup-tf-backend.sh
./scripts/setup-tf-backend.sh
```

Note the output values for the GitHub Secrets below.

---

### Step 3 — Add GitHub Secrets

Go to: `Settings → Secrets and variables → Actions → New repository secret`

| Secret Name           | Value                                      |
|-----------------------|--------------------------------------------|
| `ARM_CLIENT_ID`       | Service Principal `clientId`               |
| `ARM_CLIENT_SECRET`   | Service Principal `clientSecret`           |
| `ARM_SUBSCRIPTION_ID` | Your Azure Subscription ID                 |
| `ARM_TENANT_ID`       | Your Azure Tenant ID                       |
| `TF_BACKEND_RG`       | Resource group for backend storage         |
| `TF_BACKEND_SA`       | Storage account name for Terraform state   |
| `TF_BACKEND_CONTAINER`| Blob container name (e.g. `tfstate`)       |
| `TF_BACKEND_LOCATION` | Azure region (e.g. `eastus`)               |

---

### Step 4 — Configure Manual Approval Environment

1. Go to: `Settings → Environments → New environment`
2. Name it: **`production`**
3. Enable **Required reviewers** → add your team members
4. Save

The `terraform-apply` job will pause and wait for reviewer approval before running.

---

### Step 5 — Push and Test

```bash
# Create a feature branch
git checkout -b feature/my-infra-change

# Make a change to terraform/
# Push and open a PR
git push origin feature/my-infra-change
```

The pipeline will:
1. ✅ Scan with Checkov
2. ✅ Run `terraform plan`
3. ✅ Post the plan output as a PR comment
4. ✅ Wait for PR merge
5. ✅ Wait for manual approval
6. ✅ Run `terraform apply`

---

## File Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform-azure.yml     ← Main CI/CD pipeline
├── terraform/
│   ├── backend.tf                  ← Remote backend configuration
│   ├── main.tf                     ← Your Azure resources
│   ├── variables.tf                ← Input variables
│   └── outputs.tf                  ← Output values
└── scripts/
    └── setup-tf-backend.sh         ← One-time backend setup script
```
