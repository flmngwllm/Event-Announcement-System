output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.REGION}.amazonaws.com/${aws_api_gateway_stage.Prod_stage.stage_name}"
}

output "s3_website_url" {
  value       = aws_s3_bucket.event_announcement.website_endpoint
  description = "URL of the S3 static website"
}