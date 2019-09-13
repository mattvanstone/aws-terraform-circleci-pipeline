################
# Backend Bucket
################
resource "aws_s3_bucket" "tf-state-bucket" {
  # Update backend.tf with new value
  bucket        = "${lower(lookup(var.common_tags, "pipeline"))}-${var.env}-state-bucket"
  force_destroy = true
  acl           = "private"
  tags          = "${var.common_tags}"
  versioning {
    enabled = true
  }
}

########################
# Backend Dynamodb Table
########################
resource "aws_dynamodb_table" "tf-state-table" {
  # Update backend.tf with new value
  name         = "${lower(lookup(var.common_tags, "pipeline"))}-${var.env}-state-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = "${var.common_tags}"
}