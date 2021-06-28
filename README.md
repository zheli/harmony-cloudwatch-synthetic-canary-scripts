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

## Implementation
There are two types of endpoint checks:
1. If the canary check doesn't have it's own JS file under `terraform/scripts`
   folder. The check will use the generic JS script, which is generated using [a
   template](terraform/templates/generic_test.tmpl.js).
1. If there is JS file that has the same name with Canary, the check will use
   this file instead. They should be located under
   [terraform/scripts](terraform/scripts) folder.

## Add a new canary using generic JS script
You can add new canary by adding a new entry in `rpc_methods.tf` file, the
structure is like below:
```
"{canary_name}": {
  "method" : "{rpc_method_name}",
  "params" : [],
  # the result type, this is always verified.
  "result_type" : "number",
  # whether to compare the result with expected_result value
  "verify_result" : true
  "expected_result" : "0"
}
```
