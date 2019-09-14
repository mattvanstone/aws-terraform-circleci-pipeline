#!/bin/bash
# This script unconfigures the s3 backend and destroys all resources
if [ "$1" != "" ]; then
    mv backend.tf backend
    terraform init -force-copy -lock=false
    terraform destroy -auto-approve -var="env=$1"
    mv backend backend.tf
else
    echo "Usage: $0 [env]"
fi