resource "aws_dynamodb_table" "results_data_db" {
  name         = var.db_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "RESULT_ID"
    type = "S"
  }
  hash_key = "RESULT_ID"
}