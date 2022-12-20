# EC2 instance policy
data "aws_iam_policy_document" "ec2_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Jenkins backups
resource "aws_iam_role" "jenkins_backups" {
  name               = "jenkins-backups"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_policy.json
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-backups"
  role = aws_iam_role.jenkins_backups.id
}

resource "aws_iam_role_policy" "allow_backup_access" {
  name = "allow-jenkins-backups-access"
  role = aws_iam_role.jenkins_backups.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = ["${module.jenkins_state.bucket_arn}"]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = ["${module.jenkins_state.bucket_arn}/*"]
      }
    ]
  })

  depends_on = [module.jenkins_state]
}

# Vault Role for IAM and S3 access
resource "aws_iam_role" "vault" {
  name               = "vault"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_policy.json
}

resource "aws_iam_instance_profile" "vault" {
  name = "vault"
  role = aws_iam_role.vault.id
}

resource "aws_iam_role_policy" "vault_iam_storage_access" {
  name = "allow-vault-iam-storage-access"
  role = aws_iam_role.vault.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DescribeReservedCapacityOfferings",
          "dynamodb:DescribeReservedCapacity",
          "dynamodb:ListTables",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:CreateTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:GetRecords",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ],
        Resource = ["${module.vault_dynamodb.table_arn}"]
      },
      {
        Effect = "Allow",
        Action = [
          "iam:AttachUserPolicy",
          "iam:CreateAccessKey",
          "iam:CreateUser",
          "iam:DeleteAccessKey",
          "iam:DeleteUser",
          "iam:DeleteUserPolicy",
          "iam:DetachUserPolicy",
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:ListAttachedUserPolicies",
          "iam:ListGroupsForUser",
          "iam:ListUserPolicies",
          "iam:PutUserPolicy",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup"
        ],
        Resource = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"]
      }
    ]
  })

  depends_on = [module.vault_dynamodb]
}
