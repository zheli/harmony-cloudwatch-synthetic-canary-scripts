# harmony-cloudwatch-synthetic-canary-scripts
AWS Cloudwatch Synthetics Canary scripts for every RPC method and workflow.

## Execution
Make sure your credential is stored in `~/.aws/credentials`. If not, create it by:
1. create an access key: https://console.aws.amazon.com/iam/home?#/security_credentials
2. configure AWS CLI to store your credentials: `aws configure`

Create canaries using Terraform:
```
terraform init
terraform apply -var="account_id={your aws account id}" -var="s3={s3 bucket name for log storage}"
```

##
