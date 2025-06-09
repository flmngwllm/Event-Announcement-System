resource "aws_api_gateway_rest_api" "api" {
  name = "API"
}


resource "aws_api_gateway_resource" "events" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "events"
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_method" "events_get_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.events.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_integration" "events_get_integration" {

  http_method             = aws_api_gateway_method.events_get_method.http_method
  resource_id             = aws_api_gateway_resource.events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.events.arn}/invocations"
  integration_http_method = "POST"
}


resource "aws_api_gateway_resource" "new_events" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "new_events"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "new_events_put_method" {
  authorization = "NONE"
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.new_events.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_integration" "new_events_put_integration" {
  http_method             = aws_api_gateway_method.new_events_put_method.http_method
  resource_id             = aws_api_gateway_resource.new_events.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.create_events.arn}/invocations"
  integration_http_method = "POST"
}




resource "aws_api_gateway_resource" "subscribe" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "subscribe"
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_method" "sub_put_method" {
  authorization = "NONE"
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.subscribe.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_integration" "sub_put_integration" {

  http_method             = aws_api_gateway_method.sub_put_method.http_method
  resource_id             = aws_api_gateway_resource.subscribe.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.subscribe.arn}/invocations"
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.events.id,
      aws_api_gateway_method.events_get_method.id,
      aws_api_gateway_integration.events_get_integration.id,
      aws_api_gateway_resource.new_events.id,
      aws_api_gateway_method.new_events_put_method.id,
      aws_api_gateway_integration.new_events_put_integration.id,
      aws_api_gateway_resource.subscribe.id,
      aws_api_gateway_method.sub_put_method.id,
      aws_api_gateway_integration.sub_put_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "Prod_stage" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "PROD"
}