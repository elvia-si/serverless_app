output "userPoolId" {
  value = aws_cognito_user_pool.pool.id
}

output "userPoolClientId" {
  value = aws_cognito_user_pool_client.client.id
}

output "Rides_ARN" {
  value = aws_dynamodb_table.rides_table.arn
}

