# AWS Enterprise Landing Zone Modernization — Hands‑On MVP
**Last updated:** 2025-10-16

This repo is a **hands-on, Terraform-first MVP** to demo a modernized landing zone:

**North Star demo:** _Provision a new BU account via Account Factory → deploy a golden‑path app → auto-tag → budget alerts → dashboards._

## What you will build (MVP scope)
- **Org bootstrap:** AWS Organizations, baseline **SCPs**, **IAM Identity Center**, **org-level CloudTrail/Config**.
- **Network hub:** **Transit Gateway** + shared VPC endpoints (minimal demo).
- **Account vending (simulated Account Factory):** **AWS Service Catalog** product that deploys a paved path (**ECS Fargate webapp + Aurora Serverless v2**).
- **Observability:** CloudWatch dashboards + basic **OTel** traces (sidecar).
- **FinOps:** **CUR → S3/Athena**, Cost Categories, Budgets/alerts, tag enforcement.
- **Security:** **GuardDuty**, **Security Hub** (CIS v1.4), starter **Conformance Packs**.

> Note: AWS Control Tower APIs are limited for Terraform. This MVP uses **Organizations + SCPs** and **Service Catalog** to simulate Account Factory; you’ll narrate “Control Tower” in interviews while explaining trade‑offs.

## Timeboxes (Not-to-Exceed)
- **MVP (demo + repo + 90s video): ≤ 40 hours**
- Full polish (2nd golden path, more guardrails): **60–80 hours**

## Prereqs
- Terraform ≥ 1.7, AWS CLI v2, `jq`, `graphviz`, Docker (for OTel sidecar), Make.
- An AWS management account with **Organizations enabled** and admin role.
- **Region:** use `us-east-1` for CUR; app stacks can use your preferred region.
- **Cost safety:** Budgets + `make destroy` at the end of each session.

## Workflow
1. `aws configure sso` (or static creds) → `aws sso login --profile mgmt`
2. `make init` → `make plan` → `make apply` in each env.
3. Use console **only to explore**, then **backport** to Terraform.

## Structure
```
landing-zone/
  README.md
  Makefile
  GUIDE.md
  /modules/{org,scp,iam_idc,logging,tgw,service_catalog,ecs,eks,lambda,aurora}
  /envs/{dev,stage,prod}/main.tf
  /golden-paths/{ecs-webapp,eks-app,lambda-api}/
  /observability/{otel,cloudwatch,amg}/
  /finops/{cur,athena,cost-categories,budgets}/
  /security/{guardduty,securityhub,conformance-packs,waf}/
  /scripts/
```
