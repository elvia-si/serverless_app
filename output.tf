output "userPoolId" {
 value = aws_cognito_user_pool.pool.id
}

output "userPoolClientId" {
 value = aws_cognito_user_pool_client.client.id
}