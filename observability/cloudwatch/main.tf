resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "lz-platform"
  dashboard_body = jsonencode({
    widgets = [{
      type = "metric",
      x    = 0, y = 0, width = 24, height = 6,
      properties = {
        metrics = [["AWS/EC2", "CPUUtilization", { "stat" : "Average" }]]
        period  = 300
        region  = var.region
        title   = "Infra Overview"
      }
    }]
  })
}

variable "region" {
  type    = string
  default = "us-east-1"
}
