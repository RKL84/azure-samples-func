using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace AzureSamples.FunctionApp
{
    public static class ReadSecret
    {
        [FunctionName("ReadSecret")]
        public static async Task<IActionResult> Run(
           [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
        {
            string secretName = req.Query["secret"];
        }
    }
}
