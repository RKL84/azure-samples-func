using System;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace AzureSamples.FunctionApp
{
    public class ReadSecret
    {
        private readonly IConfiguration _configuration;
        public ReadSecret(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        //https://learn.microsoft.com/en-us/dotnet/api/overview/azure/service-to-service-authentication?view=azure-dotnet
        [FunctionName("ReadSecret")]
        public  async Task<IActionResult> Run(
           [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] HttpRequest req, ILogger log)
        {
            string secretName = req.Query["secret"];
            string keyVaultUri = _configuration["keyVaultUri"];
            log.LogInformation($"GetKeyVaultSecret request received for secret {secretName}");
            var keyVaultClient = new SecretClient(new Uri(keyVaultUri), new DefaultAzureCredential());
            string secretValue = string.Empty;
            try
            {
                KeyVaultSecret secret = await keyVaultClient.GetSecretAsync(secretName);
                secretValue = secret.Value;
            }
            catch (Exception ex)
            {
                throw ex;
            }

            log.LogInformation("Secret Value retrieved from KeyVault.");
            return new OkObjectResult(secretValue);
        }
    }
}
