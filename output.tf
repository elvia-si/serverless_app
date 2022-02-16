output "userPoolId" {
  value = aws_cognito_user_pool.pool.id
}

output "userPoolClientId" {
  value = aws_cognito_user_pool_client.client.id
}

output "Rides_ARN" {
  value = aws_dynamodb_table.rides_table.arn
}

output "invokeUrl" {
  description = "Deployment invoke url"
  value       = aws_api_gateway_deployment.rides_deployment.invoke_url
}


