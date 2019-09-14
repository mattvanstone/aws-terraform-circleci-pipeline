# Additional backend config in *.tfbackend
terraform {
  backend "s3" {
    key = "terraform.tfstate"
  }
}