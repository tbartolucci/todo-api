resource "aws_dynamodb_table" "todo-dynamodb-table" {
  name           = "todo_list"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Uuid"

  attribute {
    name = "Uuid"
    type = "S"
  }

#  ttl {
#    attribute_name = "TimeToExist"
#     enabled = false
#  }

  tags {
    Name        = "dynamodb-todo-table"
    Environment = "production"
  }
}