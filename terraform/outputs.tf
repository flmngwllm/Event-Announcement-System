output "api_gateway_base_url" {
  value       = "${aws_api_gateway_deployment.deploy.invoke_url}/${aws_api_gateway_stage.Prod_stage.stage_name}"
  description = "Base URL for API Gateway"
}

output "s3_website_url" {
  value       = aws_s3_bucket.event_announcement.website_endpoint
  description = "URL of the S3 static website"
}