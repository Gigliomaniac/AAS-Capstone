# Tip - comment out multiple lines of code with ctrl + /
# Overall issue is an instance isn't able to connect to the internet
# Solvable issues: 
# One EC2 instance wasn't deployed with a public IPv4 address
# SG that's associated to the instance doesn't support HTTP/HTTPS
# VPC NACL is also misconfigured. Denies all in/ob traffic.
# 
# Subnet route table that's associated to the instance is the private subnet route table
# private route table is configured for: dest 10.3.0.0/16 target: local
# public route table is the same, but also has 0.0.0.0/0 target: internet gateway that's attached to VPC


# To produce:

# IAM temporary credentials to get into AWS - 1st to do
# Able to create an IAM account that can be logged into, with all information to do so in a single file - COMPLETE
# Policies configured to only allow accesses to the lab

# aws secretsmanager delete-secret --secret-id temp-user-password --force-delete-without-recovery (just in case we need to get that thing gone quick)
# aws secretsmanager get-secret-value --secret-id temp-user-password --query SecretString --output text (get the secret id/password to print to screen, exclude output text if you just wanna see it appear after apply in the function lines)
# SecretString may be the key ***********

provider "aws" {
  # No region cause we're global!
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "temp_user" {
  name          = "Temp-Account-Student-${random_id.suffix.hex}"
  force_destroy = true # Terra destroy deletes user - very convenient
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_user_login_profile" "temp_user_login" {
  user                    = aws_iam_user.temp_user.name
  password_reset_required = false # No force password change - it's temporary anyway
}

output "password" {
  value     = aws_iam_user_login_profile.temp_user_login.password
  sensitive = true
}

resource "aws_secretsmanager_secret" "temp_user_secret" {
  name                           = "temp-user-password-${random_id.suffix.hex}"
  force_overwrite_replica_secret = true
  recovery_window_in_days        = 0 # Deletes IMMEDIATELY on Terraform destroy
}

# resource "random_id" "suffix" {
#   byte_length = 4
# }

resource "aws_secretsmanager_secret_version" "temp_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.temp_user_secret.id       # references lines 31-33
  secret_string = aws_iam_user_login_profile.temp_user_login.password # references lines 21-24
}

output "secret_id" {
  value = aws_secretsmanager_secret.temp_user_secret.id
}

# This was configued originally as EOT to run multiple commands to append various information to a single file. Appending just didn't work as intended; as such, we've separated them into multiple local-exectutors
# Getting this one to work was very needed
# "plainpass_${timestamp()}_${random_id.suffix.hex}.txt" - input this instead if the chances of people creating the lab within the same second become statistically significant - 
resource "null_resource" "save_credentials" {
  provisioner "local-exec" {
    command = <<EOT
        aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.temp_user_secret.name} --query SecretString --output text > plainpass-${random_id.suffix.hex}.txt
    EOT
  }
  depends_on = [aws_secretsmanager_secret_version.temp_user_secret_version]
}

# references data module for the account ID to be auto-generated in the iam_credentials file!
resource "null_resource" "login_url_addition" {
  provisioner "local-exec" {
    command = "echo Login URL: https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console > login_url-${random_id.suffix.hex}.txt"
  }

  depends_on = [data.aws_caller_identity.current]
}

resource "null_resource" "Username_addition" {
  provisioner "local-exec" {
    command = "echo Username: ${aws_iam_user.temp_user.name} > Username-${random_id.suffix.hex}.txt"
  }
}

# WE FINALLY STRUCK GOLD - WHY DOES LOCAL-EXEC RECOGNIZE NOT ECHO, NOT CAT, BUT TYPE?????
resource "null_resource" "Perfect_Cell" {
  provisioner "local-exec" {
    command = "type plainpass-${random_id.suffix.hex}.txt login_url-${random_id.suffix.hex}.txt Username-${random_id.suffix.hex}.txt > iam_credentials-${random_id.suffix.hex}.txt"
  }
  depends_on = [null_resource.save_credentials]
}


# Failed combination command attempts
# cat plainpass.txt login_url.txt username.txt > iam_credentials.txt - underneath command =
# command = "Get-Content plainpass.txt, login_url.txt, username.txt | Set-Content iam_credentials.txt"
# powershell -Command "Get-Content plainpass.txt, login_url.txt, username.txt | Set-Content iam_credentials.txt" - underneath command =
# command = "sh -c 'cat plainpass.txt login_url.txt Username.txt> iam_credentials.txt'"

# resource "aws_iam_access_key" "temp_user_keys" {
#   user = aws_iam_user.temp_user.name
# }

resource "null_resource" "cleanup_files" {
  provisioner "local-exec" {
    command = "del /f /q plainpass*.txt login_url*.txt Username*.txt iam_credentials*.txt" # Deletes the files generated earlier for cleanup
    when = destroy # Only deletes them when terra destroy is run!
  }

  lifecycle {
    prevent_destroy = false # Just eneables the files to be deleted
  }

  depends_on = [
    null_resource.Perfect_Cell
  ]
}


# Policy generation for the IAM acc

# Handles permissions for a lot of services, and explicitly allows EC2, EC2 Auto Scaling, ELB, ELB v2?
# In the original iteration of the lab, some of these permissions feel superfulous, but hey, could always figure out why my thinking is borked
# The permissions (statement arrays) had to be synced to one long item. Looks a little goofy, but just stick to counting the squigly brackets
resource "aws_iam_policy" "Troubleshooting_Connectivity_SG_NACLs" {
  name   = "PoliciesAB"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAllPermissions",
            "Effect": "Allow",
            "NotAction": [
                "lightsail:*",
                "sagemaker:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "cloudUserPermissions",
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# attaches the policy to the dynamically created IAM user via username on instance of creation
# could use depends_on = [aws_iam_user.temp.user] after policy arn w/ an extra line of space if needed. We'll see
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.temp_user.name
  policy_arn = aws_iam_policy.Troubleshooting_Connectivity_SG_NACLs.arn

  depends_on = [
    aws_iam_user.temp_user,
    aws_iam_policy.Troubleshooting_Connectivity_SG_NACLs
  ]
}
