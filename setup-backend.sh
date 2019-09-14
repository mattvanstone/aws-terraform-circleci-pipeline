#!/bin/bash
# This script initializes the backend s3 bucket and dynamodb lock table
if [ "$1" != "" ]; then
    #rm -Rf .terraform
    mv backend.tf backend
    terraform init
    terraform apply \
        -target=aws_s3_bucket.tf-state-bucket \
        -target=aws_dynamodb_table.tf-state-table \
        -auto-approve \
        -var="env=$1"
    mv backend backend.tf
    terraform init -force-copy -backend-config=$1.tfbackend
else
    echo "Usage: $0 [env]"
fi