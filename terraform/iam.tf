resource "aws_iam_role" "main" {
  name               = "CloudWatchSyntheticsRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.main_assume.json
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

data "aws_iam_policy_document" "main_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "main" {
  name        = "synthetics-policy"
  description = "Cloudwatch Synthetics Policy."
  policy      = data.aws_iam_policy_document.canary.json
}

data "aws_iam_policy_document" "canary" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::zheli-cloudwatch-test/*"]
    actions   = ["s3:PutObject"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::zheli-cloudwatch-test/*"]
    actions   = ["s3:GetBucketLocation"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:eu-west-1:${var.account_id}:log-group:/aws/lambda/"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:ListAllMyBuckets",
      "xray:PutTraceSegments",
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]
    actions   = ["cloudwatch:PutMetricData"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["CloudWatchSynthetics"]
    }
  }
}
