module "scp" {
  source = "../../modules/scp"
}

module "iam_idc" {
  source = "../../modules/iam_idc"
}

module "tgw" {
  source = "../../modules/tgw"
}

module "service_catalog" {
  source = "../../modules/service_catalog"
}

module "ecs" {
  source = "../../modules/ecs"
}

module "observability_cloudwatch" {
  source = "../../observability/cloudwatch"
}

module "observability_otl" {
  source = "../../observability/otel"
}

module "security" {
  source = "../../security/securityhub"
}
