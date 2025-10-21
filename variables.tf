variable "profile" {
  type    = string
  default = "mgmt"
}
variable "region" {
  type    = string
  default = "us-west-2"
}

variable "org_unit_names" {
  type    = list(string)
  default = ["Sandbox", "SharedServices", "Workloads"]
}

variable "log_bucket_name" {
  type    = string
  default = "lz-org-logs-1760725873"
}
