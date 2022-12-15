data "aws_iam_policy_document" "ec2_instance_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

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
