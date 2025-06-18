locals {
    lambda_alarms = {
        create_events = aws_lambda_function.create_events.function_name
        subscribe     = aws_lambda_function.subscribe.function_name
        events        = aws_lambda_function.events.function_name
    }

    lambda_functions = {
        create_events = aws_lambda_function.create_events.function_name
        subscribe     = aws_lambda_function.subscribe.function_name
        events        = aws_lambda_function.events.function_name
    }
}

resource "aws_cloudwatch_log_group" "lambda_functions_logs" {
  for_each = local.lambda_functions
  name = "/aws/lambda/${each.value}"
  retention_in_days = 7

  tags = {
    Environment = "production"
    Application = "Event_Announcements"
  }
}


resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = local.lambda_alarms
  alarm_name                = "${each.key}_errors"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = 60
  statistic                 = "Sum"
  treat_missing_data        = "notBreaching"
  threshold                 = 0
  alarm_description         = "Alarm when ${each.key} Lambda returns errors"
  dimensions = {
    FunctionName = each.value
  }
  alarm_actions = [aws_sns_topic.alarm_notifications.arn]
}



resource "aws_cloudwatch_log_stream" "foo" {
  name           = "SampleLogStream1234"
  log_group_name = aws_cloudwatch_log_group.yada.name
}

resource "aws_cloudwatch_log_delivery" "example" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.example.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.example.arn

  field_delimiter = ","

  record_fields = ["event_timestamp", "event"]
}

resource "aws_cloudwatch_log_delivery_destination" "example" {
  name = "example"

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.example.arn
  }
}

resource "aws_cloudwatch_log_delivery_source" "example" {
  name         = "example"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagent_knowledge_base.example.arn
}

resource "aws_cloudwatch_log_destination" "test_destination" {
  name       = "test_destination"
  role_arn   = aws_iam_role.iam_for_cloudwatch.arn
  target_arn = aws_kinesis_stream.kinesis_for_cloudwatch.arn
}

data "aws_iam_policy_document" "test_destination_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "123456789012",
      ]
    }

    actions = [
      "logs:PutSubscriptionFilter",
    ]

    resources = [
      aws_cloudwatch_log_destination.test_destination.arn,
    ]
  }
}

resource "aws_cloudwatch_log_destination_policy" "test_destination_policy" {
  destination_name = aws_cloudwatch_log_destination.test_destination.name
  access_policy    = data.aws_iam_policy_document.test_destination_policy.json
}
