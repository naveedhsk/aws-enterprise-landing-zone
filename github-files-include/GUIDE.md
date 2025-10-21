# GUIDE — Step-by-step Commands & Tasks (Cut, Paste, Go)

> **Rule of thumb:** Do the **MVP path** first. If something is slow, stub it and move on. Ship a runnable demo.

---
## 0) Bootstrap your local environment
```bash
# Create and activate a Python venv only if you want helper scripts (optional)
python3 -m venv .venv && source .venv/bin/activate

# Profiles (use SSO if you can)
aws configure sso --profile mgmt
aws sso login --profile mgmt

# Export common vars (adjust to your account/OU names)
export AWS_PROFILE=mgmt
export AWS_REGION=us-east-1
export TF_CLI_ARGS_plan="-compact-warnings"
```

---
## 1) Makefile (single entrypoint)
The repo includes a Makefile. Key targets:
```bash
make init          # terraform init in working dir
make plan          # terraform plan
make apply         # terraform apply -auto-approve
make destroy       # terraform destroy -auto-approve
make fmt           # terraform fmt -recursive
make validate      # terraform validate
make graph         # outputs dependency graph (graphviz)
```

---
## 2) Organizations + SCPs + Org Logging (MVP)
- Creates an **AWS Organization**, top-level **OUs**, baseline **SCPs** (deny root access keys, deny public S3, require tags), and **org-level CloudTrail + AWS Config** to a central logging bucket.

**Run (from `envs/dev`)**
```bash
cd envs/dev
make init && make apply
```

**Core resources (Terraform modules)**
- `modules/org`: `aws_organizations_organization`, OUs, CloudTrail (org), Config aggregator, S3 log bucket, KMS.
- `modules/scp`: baseline SCP JSONs + `aws_organizations_policy` attachments.
- `modules/iam_idc`: creates Identity Center instance + permission sets (note: some manual/CLI steps are still required; see module README).

**Useful CLI checks**
```bash
aws organizations describe-organization
aws cloudtrail list-trails --query "trailList[?IsOrganizationTrail].Name"
aws configservice describe-configuration-aggregators
```

---
## 3) Network Hub (TGW) — minimal
- Creates a **Transit Gateway**, a demo **shared services VPC**, and attaches the VPC to TGW.
```bash
cd envs/dev && terraform apply -target=module.tgw
```

---
## 4) Service Catalog “Account Factory” (simulated) + Golden Path
- Creates a **Portfolio** for “BU Onboarding” and a **Product** backed by a CloudFormation template that deploys **ECS Fargate + ALB + Aurora Serverless v2** with standard **tags/budgets**.
- Associates **Permission Sets** (via Identity Center) so a BU admin can launch the product.

**Run**
```bash
cd envs/dev && terraform apply -target=module.service_catalog -target=module.ecs
```

**Launch flow (console)**
1. Go to **Service Catalog → Products → BU Golden Path (ECS)**.
2. Launch with parameters: `AppName`, `Env`, `VPCCidr`, `MinCapacity`, etc.
3. Verify: ALB DNS responds, task is healthy, Aurora cluster present.

---
## 5) Observability Starter Kit
- Deploys an **OTel collector** (sidecar) and a **CloudWatch dashboard**; enables **X-Ray** for traces.

**Run**
```bash
cd envs/dev && terraform apply -target=module.observability_otl -target=module.observability_cloudwatch
```

**Quick checks**
```bash
aws xray get-service-graph --start-time $(date -v-10M +%s) --end-time $(date +%s) --region $AWS_REGION
```

---
## 6) FinOps Lite
- **CUR** report (must be in **us-east-1**), **Athena** database/table, **Cost Categories**, and **Budgets** with email alerts.

**Run**
```bash
cd envs/dev && terraform apply -target=module.finops
```

**Query CUR (Athena)**
```bash
aws athena start-query-execution   --query-string "SELECT bill_payer_account_id, SUM(line_item_unblended_cost) AS cost FROM cur_view GROUP BY bill_payer_account_id ORDER BY cost DESC LIMIT 10"   --query-execution-context Database=cur_db --result-configuration OutputLocation=s3://<YOUR-CUR-QUERY-BUCKET>/athena/
```

---
## 7) Security Hardening
- Enables **GuardDuty** (org), **Security Hub** with CIS benchmark, and a couple of **Conformance Packs**.
```bash
cd envs/dev && terraform apply -target=module.security
```

---
## 8) Teardown
```bash
# Per env
cd envs/dev && make destroy

# S3 buckets must be emptied before destroy if they contain objects (CloudTrail/CUR)
aws s3 rm s3://<YOUR-LOG-BUCKET> --recursive
aws s3 rm s3://<YOUR-CUR-BUCKET> --recursive
```

---
## 9) Video & LinkedIn (final steps)
1. Finish README diagram + STAR bullets.
2. Record a 90-sec Loom/OBS demo (script included in README).
3. LinkedIn post in Oct 2025: “Built in 2024; sharing lessons.” Focus on outcomes + trade-offs.
