# Things to look into/add

## retrieve the state file to find secrets

```
data "terraform_remote_state" "admin" {
  backend = "local"

  config = {
    path = var.path
  }
} 
```
## pull creds

```
data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
} 


resource "null_resource" "start-appstream-fleet" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOF
set -e
CREDENTIALS=(`aws sts assume-role \
  --role-arn ${local.workspace.role} \
  --role-session-name "start-appstream-fleet" \
  --query "[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]" \
  --output text`)

unset AWS_PROFILE
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID="$${CREDENTIALS[0]}"
export AWS_SECRET_ACCESS_KEY="$${CREDENTIALS[1]}"
export AWS_SESSION_TOKEN="$${CREDENTIALS[2]}"

aws appstream start-fleet --name sample-app-${var.environment}-fleet --region ${var.region} --output json
EOF
  }
}
```
