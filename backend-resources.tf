################
# Backend Bucket
################
resource "aws_s3_bucket" "tf-state-bucket" {
  # Update backend.tf with new value
  bucket = "[pipeline-name]-dev-state-bucket"
  versioning {
    enabled = true
  }
  acl = "private"
  tags = "${var.common_tags}"
}

########################
# Backend Dynamodb Table
########################
resource "aws_dynamodb_table" "tf-state-table" {
  # Update backend.tf with new value
  name         = "[pipeline-name]-dev-state-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = "${var.common_tags}"
}