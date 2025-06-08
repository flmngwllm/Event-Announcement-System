resource "aws_sns_topic" "sns_event_announce" {
  name = "event_announce_topic"
}

/*
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.sns_event_announce.arn
}


resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.sns_event_announce.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.subscribe.arn
}
*/