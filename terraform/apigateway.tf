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

# /events OPTIONS (CORS)
resource "aws_api_gateway_method" "events_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.events.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "events_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.events.id
  http_method             = aws_api_gateway_method.events_options.http_method
  type                    = "MOCK"
  integration_http_method = "OPTIONS"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "events_options_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [
    aws_api_gateway_method.events_options
  ]
}

resource "aws_api_gateway_integration_response" "events_options_integration_response" {
  depends_on = [
    aws_api_gateway_method_response.events_options_response,
    aws_api_gateway_integration.events_options_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
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

# /new_events OPTIONS (CORS)
resource "aws_api_gateway_method" "new_events_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.new_events.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "new_events_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.new_events.id
  http_method             = aws_api_gateway_method.new_events_options.http_method
  type                    = "MOCK"
  integration_http_method = "OPTIONS"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "new_events_options_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.new_events.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.new_events_options
  ]
}

resource "aws_api_gateway_integration_response" "new_events_options_integration_response" {
  depends_on = [
    aws_api_gateway_method.new_events_options_response,
    aws_api_gateway_integration.new_events_options_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.new_events.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
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

# /subscribe OPTIONS (CORS)
resource "aws_api_gateway_method" "subscribe_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.subscribe.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "subscribe_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.subscribe.id
  http_method             = aws_api_gateway_method.subscribe_options.http_method
  type                    = "MOCK"
  integration_http_method = "OPTIONS"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "subscribe_options_response" {

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.subscribe.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.subscribe_options
  ]
}

resource "aws_api_gateway_integration_response" "subscribe_options_integration_response" {
  depends_on = [
    aws_api_gateway_method_response.subscribe_options_response,
    aws_api_gateway_integration.subscribe_options_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.subscribe.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
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
      aws_api_gateway_method.events_options.id,
      aws_api_gateway_method_response.events_options_response.id,
      aws_api_gateway_integration.events_options_integration.id,
      aws_api_gateway_integration_response.events_options_integration_response.id,

      aws_api_gateway_resource.new_events.id,
      aws_api_gateway_method.new_events_put_method.id,
      aws_api_gateway_integration.new_events_put_integration.id,
      aws_api_gateway_method.new_events_options.id,
      aws_api_gateway_method_response.new_events_options_response.id,
      aws_api_gateway_integration.new_events_options_integration.id,
      aws_api_gateway_integration_response.new_events_options_integration_response.id,

      aws_api_gateway_resource.subscribe.id,
      aws_api_gateway_method.sub_put_method.id,
      aws_api_gateway_integration.sub_put_integration.id,
      aws_api_gateway_method.subscribe_options.id,
      aws_api_gateway_method_response.subscribe_options_response.id,
      aws_api_gateway_integration.subscribe_options_integration.id,
      aws_api_gateway_integration_response.subscribe_options_integration_response.id

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