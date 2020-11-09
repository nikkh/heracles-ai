using System;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;

namespace Thessaloniki
{
#pragma warning disable CS1591
    public class Program
    {
        public static void Main(string[] args)
        {
            var aiKey = Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY");
            Console.WriteLine("AIKey=" + aiKey);
            CreateWebHostBuilder(args).Build().Run();
        }
        // TODO Resolve Deprecation
        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseApplicationInsights()
                .UseStartup<Startup>()
                .ConfigureLogging(
                    builder =>
                    {
                        // Providing an instrumentation key here is required if you're using
                        // standalone package Microsoft.Extensions.Logging.ApplicationInsights
                        // or if you want to capture logs from early in the application startup
                        // pipeline from Startup.cs or Program.cs itself....
                        builder.AddApplicationInsights(Environment.GetEnvironmentVariable("APPINSIGHTS_INSTRUMENTATIONKEY"));


                    });
    }
#pragma warning restore CS1591
}
