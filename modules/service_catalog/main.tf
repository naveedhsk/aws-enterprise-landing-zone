# Portfolio + Product (ECS Golden Path)
resource "aws_servicecatalog_portfolio" "bu_onboarding" {
  name          = "BU Onboarding"
  provider_name = "Platform Team"
}

resource "aws_s3_bucket" "templates" {
  bucket        = "lz-sc-templates-1760752520"
  force_destroy = true
}

# Upload ECS Fargate CloudFormation template to S3
resource "aws_s3_object" "ecs_tpl" {
  bucket  = aws_s3_bucket.templates.id
  key     = "ecs-fargate.yml"
  content = file("${path.module}/templates/ecs-fargate.yml")
}

resource "aws_servicecatalog_product" "ecs_gp" {
  name  = "Golden Path - ECS"
  owner = "Platform Team"
  type  = "CLOUD_FORMATION_TEMPLATE"
  provisioning_artifact_parameters {
    name         = "v1"
    template_url = "https://${aws_s3_bucket.templates.bucket}.s3.amazonaws.com/${aws_s3_object.ecs_tpl.key}"
    type         = "CLOUD_FORMATION_TEMPLATE"
  }
}

resource "aws_servicecatalog_product_portfolio_association" "assoc" {
  portfolio_id = aws_servicecatalog_portfolio.bu_onboarding.id
  product_id   = aws_servicecatalog_product.ecs_gp.id
}

# Grant access to IAM user
resource "aws_servicecatalog_principal_portfolio_association" "user_access" {
  portfolio_id  = aws_servicecatalog_portfolio.bu_onboarding.id
  principal_arn = "arn:aws:iam::653091864212:user/naveedh"
}
