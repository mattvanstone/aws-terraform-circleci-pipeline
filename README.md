# aws-terraform-circleci-pipeline
This is a basic CI/CD pipeline template for projects using AWS, Terraform, and CircleCI. It supports a develop branch for non-prod and a master branch for production. Commits to develop or master will run terraform apply on the associated context. Commits to any other branch will run terraform plan against the develop context. The promotion through environments is any to develop to master.

## Assumptions
- All of the resources in development and prod are identical
- After setting up the pipeline you never intend to run terraform destroy. Since this pipeline creates the backend resources destroy will fail unless you first move to a local backend.

## Prerequisites
- CircleCI setup and linked to GitHub.
- Two separate AWS accounts, one for production, and one for development.
- One CircleCI context called production and a second called development with the following environment variables populated with the access keys for the separate AWS accounts:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY

## Workflow

1. Create a new branch from master called develop.
2. Create a new branch from develop and call it whatever you want (foo).
3. Commit code to foo. CircleCI will run the dev_plan job.
4. If the result of dev_plan is as expected, merge foo to develop. 
    - The dev_deploy job will run terraform apply in the dev context.
    - The prod_plan job will run terraform plan in the prod context.
5. If the result of prod_plan is as expected, merge develop to master.
    - The prod_deploy job will run terraform apply in the prod context.
6. Repeat steps 3 to 5 to code and promote changes through dev and prod.

## To Do
Only the CircleCI config has been implemented so far.
- Create Terraform for backend
- Create sample resources
- Document setup instructions

## Setup
- backend-resources.tf: Set aws_s3_bucket.tf-state-bucket.bucket and aws_dynamodb_table.tf-state-table.name
- backend.tf: Set bucket and dynamodb_table attributes
- rename backend.tf to backend
- run terraform init && terraform apply
- after successful apply rename backend to backend.tf
- run terraform init -force-copy