using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Azure.Security.KeyVault.Secrets;
using Azure.Identity;
using System.Net;

namespace AzureSamples.FunctionApp
{
    public class ReadSecretPoc
    {
        private readonly ILogger _logger;
        private readonly IConfiguration _configuration;
        public ReadSecretPoc(IConfiguration configuration, ILoggerFactory loggerFactory)
        {
            _configuration = configuration;
            _logger = loggerFactory.CreateLogger<ReadSecretPoc>();
        }

        //https://learn.microsoft.com/en-us/dotnet/api/overview/azure/service-to-service-authentication?view=azure-dotnet
        [Function("ReadSecret")]
        public async Task<HttpResponseData> RunAsync([HttpTrigger(AuthorizationLevel.Function, "get")] HttpRequestData req)
        {
            string secretName = req.Query["secret"];
            string keyVaultUri = _configuration["keyVaultUri"];
            _logger.LogInformation($"GetKeyVaultSecret request received for secret {secretName}");
            var keyVaultClient = new SecretClient(new Uri(keyVaultUri), new DefaultAzureCredential());
            string secretValue = string.Empty;
            try
            {
                KeyVaultSecret secret = await keyVaultClient.GetSecretAsync(secretName);
                secretValue = secret.Value;
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                response.WriteString(secretValue);
                return response;
            }
            catch (Exception ex)
            {
                var response = req.CreateResponse(HttpStatusCode.InternalServerError);
                response.WriteString(ex.ToString());
                return response;
            } 
        }
    }
}
