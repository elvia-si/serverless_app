resource "aws_dynamodb_table" "rides_table" {
  name           = "Rides"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "RideId"

  attribute {
    name = "RideId"
    type = "S"
  }
}