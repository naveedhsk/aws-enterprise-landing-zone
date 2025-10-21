# CUR must be in us-east-1
resource "aws_cur_report_definition" "cur" {
  provider = aws.use1
  report_name = "org-cur"
  time_unit   = "HOURLY"
  format      = "Parquet"
  compression = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket   = aws_s3_bucket.cur.bucket
  s3_region   = "us-east-1"
  s3_prefix   = "cur/"
  additional_artifacts = ["ATHENA"]
}

resource "aws_s3_bucket" "cur" {
  bucket = "lz-cur-CHANGE-ME"
  force_destroy = true
}

resource "aws_athena_database" "cur_db" {
  name   = "cur_db"
  bucket = aws_s3_bucket.cur.bucket
}
