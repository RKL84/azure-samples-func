using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AzureSamples.FunctionApp
{
    public class Program
    {
        public static void Main()
        {
            var host = new HostBuilder()
                //.ConfigureFunctionsWorkerDefaults()
                .ConfigureServices(services =>
                {
                    //services.AddDbContext(options
                    //  => Options.UseSqlServer(
                    //         Environment.GetEnvironmentVariable("MyConnection")));
                    //services.AddOptions()
                    //    .Configure((settings, configuration)
                    //         => configuration.GetSection("MyOptions").Bind(settings));
                    //services.AddScoped();
                }).Build();
            host.Run();
        }
    }
}
