data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "aws_iam_policy_document" "lambda_policy" {

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListObject",
    ]
    resources = [
      aws_s3_bucket.event_announcement.arn,
      "${aws_s3_bucket.event_announcement.arn}/*"
    ]

  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.sns_event_announce.arn,
      "${aws_sns_topic.sns_event_announce.arn}/*"
    ]

  }

}


resource "aws_iam_policy" "resource_lambda_s3_policy" {
  name   = "lambda_policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.resource_lambda_s3_policy.arn
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "lambda/lambda_functions.py"
  output_path = "lambda.zip"
}




resource "aws_lambda_function" "create_events" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda.zip"
  function_name = "create_events_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "create_events_handler"

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  runtime = "python3.12"
}


resource "aws_lambda_function" "subscribe" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda.zip"
  function_name = "subscribe_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "subscribe_handler"

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  runtime = "python3.12"
}

resource "aws_lambda_permission" "create_events_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_events.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.Prod_stage.stage_name}/PUT/new_events"


}

resource "aws_lambda_permission" "subscribe_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/${aws_api_gateway_stage.Prod_stage.stage_name}/PUT/subscribe"
}
