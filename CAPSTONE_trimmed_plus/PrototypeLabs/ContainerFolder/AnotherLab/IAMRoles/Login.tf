# this part was create via Dom
provider "aws" {
  # Configure as needed
}

data "aws_caller_identity" "identity" {}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_user" "user_account" {
  name          = "User-Account-Student-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_iam_user_login_profile" "user_account_login" {
  user                    = aws_iam_user.user_account.name
  password_reset_required = false
}

output "password" {
  value     = aws_iam_user_login_profile.user_account_login.password
  sensitive = true
}

resource "aws_secretsmanager_secret" "user_account_secret" {
  name                            = "user-account-password-${random_id.suffix.hex}"
  force_overwrite_replica_secret  = true
  recovery_window_in_days         = 0
}

resource "aws_secretsmanager_secret_version" "user_account_secret_version" {
  secret_id     = aws_secretsmanager_secret.user_account_secret.id
  secret_string = aws_iam_user_login_profile.user_account_login.password
}

output "secret_id" {
  value = aws_secretsmanager_secret.user_account_secret.id
}

resource "null_resource" "credentials" {
  provisioner "local-exec" {
    command = <<EOT
        aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.user_account_secret.name} --query SecretString --output text > plainpass-${random_id.suffix.hex}.txt
    EOT
  }
  depends_on = [aws_secretsmanager_secret_version.user_account_secret_version]
}

resource "null_resource" "url_login" {
  provisioner "local-exec" {
    command = "echo Login URL: https://${data.aws_caller_identity.identity.account_id}.signin.aws.amazon.com/console > login_url-${random_id.suffix.hex}.txt"
  }
  depends_on = [data.aws_caller_identity.identity]
}

resource "null_resource" "add_username" {
  provisioner "local-exec" {
    command = "echo Username: ${aws_iam_user.user_account.name} > Username-${random_id.suffix.hex}.txt"
  }
}

resource "null_resource" "nothing" {
  provisioner "local-exec" {
    command = "type plainpass-${random_id.suffix.hex}.txt login_url-${random_id.suffix.hex}.txt Username-${random_id.suffix.hex}.txt > iam_credentials-${random_id.suffix.hex}.txt"
  }
  depends_on = [null_resource.credentials]
}

resource "null_resource" "complete_delete" {
  provisioner "local-exec" {
    command = "del /f /q plainpass*.txt login_url*.txt Username*.txt iam_credentials*.txt"
    when    = destroy
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [null_resource.nothing]
}

# adding in the allow for policies
resource "aws_iam_policy" "user_limited_permissions" {
  name        = "user-limited-permissions-${random_id.suffix.hex}"
  description = "Allow IAM role management and basic user visibility"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowRoleAndUserManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:ListPolicies",
          "iam:GetUser",
          "iam:ListUsers",
          "iam:ListAttachedUserPolicies"
        ]
        Resource = "*"
      }
    ]
  })
}

# ensurse that the policy is attached to the users account
resource "aws_iam_user_policy_attachment" "user_policy_attach" {
  user       = aws_iam_user.user_account.name
  policy_arn = aws_iam_policy.user_limited_permissions.arn

  depends_on = [
    aws_iam_user.user_account,
    aws_iam_policy.user_limited_permissions
  ]
}
