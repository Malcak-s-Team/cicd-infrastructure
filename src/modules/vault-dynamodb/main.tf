resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.name
  read_capacity  = 4
  write_capacity = 4
  hash_key       = "Path"
  range_key      = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  tags = {
    Name = "vault-dynamodb-table"
  }

  lifecycle {
    prevent_destroy = true
  }
}
