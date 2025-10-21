resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_s3_bucket" "org_logs" {
  bucket        = var.log_bucket_name
  force_destroy = true
}

resource "aws_kms_key" "logs" {
  description             = "KMS for org logs"
  deletion_window_in_days = 7
}

resource "aws_cloudtrail" "org" {
  name                          = "org-trail"
  is_organization_trail         = true
  s3_bucket_name                = aws_s3_bucket.org_logs.id
  kms_key_id                    = aws_kms_key.logs.arn
  include_global_service_events = true
  is_multi_region_trail         = true
}

# Create organizational units
resource "aws_organizations_organizational_unit" "ou" {
  count     = length(var.org_unit_names)
  name      = var.org_unit_names[count.index]
  parent_id = aws_organizations_organization.this.roots[0].id
}
