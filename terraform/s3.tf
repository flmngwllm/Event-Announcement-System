resource "aws_s3_bucket" "event_announcement" {
  bucket = var.BUCKET_NAME
  tags = {
    Name        = var.BUCKET_NAME
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_cors_configuration" "frontend_cors" {
  bucket = aws_s3_bucket.event_announcement.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}



resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.event_announcement.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "event_announcement_policy" {
  bucket = aws_s3_bucket.event_announcement.id
  policy = data.aws_iam_policy_document.event_policy_document.json

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

data "aws_iam_policy_document" "event_policy_document" {
  statement {
    sid = "PublicReadGetObject"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.event_announcement.arn}/*",
    ]
    effect = "Allow"
  }


  statement {
    sid    = "AllowUploadsFromGitHubActions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::831274730062:user/event-notify"]
    }

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]


    resources = [
      "${aws_s3_bucket.event_announcement.arn}/*"
    ]
  }

  statement {
    sid    = "AllowListBucketForGitHubActions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::831274730062:user/event-notify"]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.event_announcement.arn}"
    ]
  }

  statement {
    sid    = "AllowLambdaAccessToBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::831274730062:role/event_lambda"]
    }


    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      aws_s3_bucket.event_announcement.arn,
      "${aws_s3_bucket.event_announcement.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.event_announcement.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


