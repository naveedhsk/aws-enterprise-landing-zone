# Baseline SCPs (attach manually to OUs as needed)
resource "aws_organizations_policy" "deny_root_keys" {
  name        = "DenyRootAccessKeys"
  description = "Deny creation of root access keys"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny-root-keys.json")
}

resource "aws_organizations_policy" "deny_public_s3" {
  name        = "DenyPublicS3"
  description = "Deny public ACLs and policies on S3"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny-public-s3.json")
}
