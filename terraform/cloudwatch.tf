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
  for_each          = local.lambda_functions
  name              = "/aws/lambda/${each.value}"
  retention_in_days = 7

  tags = {
    Environment = "production"
    Application = "Event_Announcements"
  }
}


resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each            = local.lambda_alarms
  alarm_name          = "${each.key}_errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  threshold           = 0
  alarm_description   = "Alarm when ${each.key} Lambda returns errors"
  dimensions = {
    FunctionName = each.value
  }
  alarm_actions = [aws_sns_topic.sns_event_announce.arn]
}



