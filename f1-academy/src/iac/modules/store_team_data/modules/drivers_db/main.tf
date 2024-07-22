resource "aws_dynamodb_table" "f_one_academy_drivers_data_db" {
  name         = var.drivers_data_db_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "TEAM_ID"
    type = "S"
  }
  attribute {
    name = "DRIVER_ID"
    type = "S"
  }
  hash_key  = "TEAM_ID"
  range_key = "DRIVER_ID"
}