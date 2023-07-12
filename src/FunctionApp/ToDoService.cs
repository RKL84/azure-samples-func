using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace AzureSamples.FunctionApp
{
    public class ToDoService
    {
        private readonly ILogger _logger;

        public ToDoService(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ToDoService>();
        }

        [Function("GetToDos")]
        public HttpResponseData GetToDos([HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            var response = req.CreateResponse(HttpStatusCode.OK);
            string itemId = req.Query["id"];
            var toDoItems = StaticDbStore.GetAllTodoItems();
            // switch based on request method, pass query param and/or body object to the corresponding function
            if (string.IsNullOrEmpty(itemId))
                return response;
            // return a single ToDoItem if querystring
            else
            {
                response.Headers.Add("Content-Type", "application/json");
                response.WriteString(JsonConvert.SerializeObject(toDoItems));
                return response;
            }
        }

        [Function("PostToDo")]
        public HttpResponseData PostToDo([HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            var response = req.CreateResponse(HttpStatusCode.OK);
            return response;
        }

        [Function("DeleteToDo")]
        public HttpResponseData DeleteToDo([HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            var response = req.CreateResponse(HttpStatusCode.OK);
            return response;
        }

        // create a new ToDoItem from body object
        // uses output binding to insert new item into ToDo table
        //[FunctionName("PostToDo")]
        //public static async Task<IActionResult> Run(
        //    [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "PostFunction")] HttpRequest req,
        //    ILogger log,
        //    [Sql(commandText: "dbo.ToDo", connectionStringSetting: "SqlConnectionString")] IAsyncCollector<ToDoItem> toDoItems)
        //{
        //    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        //    ToDoItem toDoItem = JsonConvert.DeserializeObject<ToDoItem>(requestBody);

        //    // generate a new id for the todo item
        //    toDoItem.Id = Guid.NewGuid();

        //    // set Url from env variable ToDoUri
        //    toDoItem.url = Environment.GetEnvironmentVariable("ToDoUri")+"?id="+toDoItem.Id.ToString();

        //    // if completed is not provided, default to false
        //    if (toDoItem.completed == null)
        //    {
        //        toDoItem.completed = false;
        //    }

        //    await toDoItems.AddAsync(toDoItem);
        //    await toDoItems.FlushAsync();
        //    List<ToDoItem> toDoItemList = new List<ToDoItem> { toDoItem };

        //    return new OkObjectResult(toDoItemList);
        //}


        //// return items from ToDo table
        //// id querystring in the query text to filter if specified
        //// uses input binding to run the query and return the results
        //[FunctionName("GetToDos")]
        //public static async Task<IActionResult> Run(
        //    [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "GetFunction")] HttpRequest req,
        //    ILogger log,
        //    [Sql(commandText: "if @Id = '' select Id, [order], title, url, completed from dbo.ToDo else select Id, [order], title, url, completed from dbo.ToDo where @Id = Id", connectionStringSetting: "SqlConnectionString", commandType: System.Data.CommandType.Text, parameters: "@Id={Query.id}")] IAsyncEnumerable<ToDoItem> toDos)
        //{
        //    return new OkObjectResult(toDos);
        //}


        //// delete all items or a specific item from querystring
        //// returns remaining items
        //// uses input binding with a stored procedure DeleteToDo to delete items and return remaining items
        //[FunctionName("DeleteToDo")]
        //public static IActionResult Run(
        //    [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "DeleteFunction")] HttpRequest req,
        //    ILogger log,
        //    [Sql(commandText: "DeleteToDo", commandType: System.Data.CommandType.StoredProcedure, 
        //        parameters: "@Id={Query.id}", connectionStringSetting: "SqlConnectionString")] 
        //        IEnumerable<ToDoItem> toDoItems)
        //{
        //    return new OkObjectResult(toDoItems);
        //}
    }
}
