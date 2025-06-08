resource "aws_s3_bucket" "event_announcement" {
  bucket = var.BUCKET_NAME
  tags = {
    Name        = var.BUCKET_NAME
    Environment = "Dev"
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


