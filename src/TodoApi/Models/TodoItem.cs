using Amazon.DynamoDBv2.DataModel;
using System;

namespace TodoApi.Models
{
    [DynamoDBTable("todo_list")]
    public class TodoItem
    {
        [DynamoDBHashKey]
        public string Uuid { get; set; }
        public string Name { get; set; }
        public int IsComplete { get; set; }

    }
}
