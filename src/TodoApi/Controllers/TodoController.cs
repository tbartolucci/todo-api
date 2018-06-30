using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.DynamoDBv2.Model;
using Amazon.Runtime;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using TodoApi.Models;
using static System.Guid;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace TodoApi.Controllers
{
    [Route("/api/[controller]/v1")]
    public class TodoController : Controller
    {
        private AmazonDynamoDBClient DynamoClient { get; set; }
        private DynamoDBContext Context { get; set; }
        private readonly String _tableName = "todo_list";

        public TodoController(IConfigurationRoot configuration)
        {
            var accessKey = configuration["aws_access_key_id"];
            var secretKey = configuration["aws_secret_access_key"];
            var credentials = new BasicAWSCredentials(accessKey, secretKey);
            DynamoClient = new AmazonDynamoDBClient(credentials, RegionEndpoint.USEast1);
            Context = new DynamoDBContext(DynamoClient);
        }

        [HttpGet]
        public async Task<IEnumerable<TodoItem>> GetAll()
        {
            var scanConditions = new Dictionary<string, Condition>();
            
            var list = new List<TodoItem>();
            var scanResponse = await DynamoClient.ScanAsync(_tableName, scanConditions );
            foreach (Dictionary<string,AttributeValue> item in scanResponse.Items)
            {
                list.Add(new TodoItem
                {
                    Uuid = item["Uuid"].S,
                    Name = item["Name"].S,
                    IsComplete = Int32.Parse(item["IsComplete"].N)
                });
            }
            return list;
        }
        

        [HttpGet("{id}", Name = "GetTodo")]
        public async Task<IActionResult> GetById(string id)
        {
            var itemResponse = await DynamoClient.GetItemAsync(_tableName, new Dictionary<string, AttributeValue>
            {
                {"Uuid", new AttributeValue {S = id}}
            });
            
            if (!itemResponse.IsItemSet)
            {
                return NotFound();
            }

            var item = new TodoItem
            {
                Uuid = itemResponse.Item["Uuid"].S,
                Name = itemResponse.Item["Name"].S,
                IsComplete = Int32.Parse(itemResponse.Item["IsComplete"].N)
            };
            
            return new ObjectResult(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] TodoItem item)
        {
            if (item == null)
            {
                return BadRequest();
            }

            item.Uuid = NewGuid().ToString();
            
            await DynamoClient.PutItemAsync(_tableName, new Dictionary<string, AttributeValue>
            {
                {"Uuid", new AttributeValue {S = item.Uuid}},
                {"Name", new AttributeValue {S = item.Name}},
                {"IsComplete", new AttributeValue {N = item.IsComplete.ToString()}}
            });
               
            return CreatedAtRoute("GetTodo", new {id = item.Uuid}, item);
        }

        /// <summary>
        /// Idempotent update to a TodoItem
        /// </summary>
        /// <param name="id"></param>
        /// <param name="item"></param>
        /// <returns></returns>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, [FromBody] TodoItem item)
        {
            if (item == null || item.Uuid != id)
            {
                return BadRequest();
            }
            
            var itemResponse = await DynamoClient.GetItemAsync(_tableName, new Dictionary<string, AttributeValue>
            {
                {"Uuid", new AttributeValue {S = id}}
            });
            
            if (!itemResponse.IsItemSet)
            {
                return NotFound();
            }
           
            await DynamoClient.PutItemAsync(_tableName, new Dictionary<string, AttributeValue>
            {
                {"Uuid", new AttributeValue {S = item.Uuid}},
                {"Name", new AttributeValue {S = item.Name}},
                {"IsComplete", new AttributeValue {N = item.IsComplete.ToString()}}
            });
       
            return new NoContentResult();
        }

        /// <summary>
        /// Deletes a specific TodoItem
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var deleteItemResponse = await DynamoClient.DeleteItemAsync(_tableName, new Dictionary<string, AttributeValue>
            {
                {"Uuid", new AttributeValue {S = id}}
            }, ReturnValue.ALL_OLD);

            if (deleteItemResponse.Attributes.Count == 0)
            {
                return NotFound();
            }
            
            return new NoContentResult();
        }
    }
}
