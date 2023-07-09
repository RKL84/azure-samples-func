using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace AzureSamples.FunctionApp
{
    public static class DeleteToDo
    {
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

        // delete all items or a specific item from querystring
        // returns remaining items
        // uses input binding with a stored procedure DeleteToDo to delete items and return remaining items
        [FunctionName("DeleteToDo")]
        public static IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "DeleteFunction")] HttpRequest req, ILogger log)
        {
            return new OkResult();
        }
    }
}
