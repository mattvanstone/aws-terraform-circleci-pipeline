terraform {
  backend "s3" {
    # Update to match bucket name defined in backend section of main.tf
    bucket = "[pipeline-name]-dev-state-bucket"
    key    = "terraform.tfstate"
    # Update to match table name defined in backend section of main.tf
    dynamodb_table = "a[pipeline-name]-dev-state-table"
    region         = "us-east-1"
  }
}