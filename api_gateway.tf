resource "aws_api_gateway_rest_api" "wild_rydes" {
  name        = "WildRydes"
  description = "API Gateway for serveless app"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "WildRydes"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.wild_rydes.id
  provider_arns = [aws_cognito_user_pool.pool.arn]
  depends_on = [
    aws_cognito_user_pool.pool
  ]
}

#end-point
resource "aws_api_gateway_resource" "ride" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  parent_id   = aws_api_gateway_rest_api.wild_rydes.root_resource_id
  path_part   = "ride"
}

#enable cors
resource "aws_api_gateway_method" "enable_cors" {
  rest_api_id   = aws_api_gateway_rest_api.wild_rydes.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cors_200" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.enable_cors.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.enable_cors
  ]
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.enable_cors.http_method
  type        = "MOCK"

  depends_on = [
    aws_api_gateway_method.enable_cors
  ]
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.enable_cors.http_method
  status_code = aws_api_gateway_method_response.cors_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [
    aws_api_gateway_method_response.cors_200
  ]
}

#POST method for lambda
resource "aws_api_gateway_method" "lambda_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.wild_rydes.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method_response" "lambda_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  resource_id = aws_api_gateway_resource.ride.id
  http_method = aws_api_gateway_method.lambda_post_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_method.lambda_post_method
  ]
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  resource_id = aws_api_gateway_method.lambda_post_method.resource_id
  http_method = aws_api_gateway_method.lambda_post_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.request_rides.invoke_arn
}

resource "aws_api_gateway_deployment" "rides_deployment" {
  rest_api_id = aws_api_gateway_rest_api.wild_rydes.id
  stage_name  = "BETA"

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}












