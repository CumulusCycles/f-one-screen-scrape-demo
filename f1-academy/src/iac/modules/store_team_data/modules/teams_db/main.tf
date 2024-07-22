resource "aws_dynamodb_table" "f_one_academy_teams_data_db" {
  name         = var.teams_data_db_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "TEAM_ID"
    type = "S"
  }
  hash_key = "TEAM_ID"
}