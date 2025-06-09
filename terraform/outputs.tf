output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.REGION}.amazonaws.com/${aws_api_gateway_stage.Prod_stage.stage_name}"
}


output "s3_website_url" {
  value = "http://${aws_s3_bucket.event_announcement.bucket}.s3-website-${var.REGION}.amazonaws.com"
}

