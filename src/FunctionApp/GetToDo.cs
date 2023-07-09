using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace AzureSamples.FunctionApp
{
    public static class GetToDos
    {
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

        [FunctionName("GetToDos")]
        public static async Task<IActionResult> Run(
           [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
        {
            string itemId = req.Query["id"];
            var toDoItems = StaticDbStore.GetAllTodoItems();
            // switch based on request method, pass query param and/or body object to the corresponding function
            if (string.IsNullOrEmpty(itemId))
                return new OkObjectResult(toDoItems);
            // return a single ToDoItem if querystring
            else
            {
                var item = toDoItems.FirstOrDefault(a => a.Id == itemId);
                return new NotFoundObjectResult(item);
            }
        }
    }
}
