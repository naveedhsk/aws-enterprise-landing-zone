terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

# us-east-1 for CUR
provider "aws" {
  alias   = "use1"
  region  = "us-east-1"
  profile = var.profile
}
