using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;

namespace Iraklion
{
#pragma warning disable CS1591
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>()
                .ConfigureLogging(
                    builder =>
                    {
                        // Providing an instrumentation key here is required if you're using
                        // standalone package Microsoft.Extensions.Logging.ApplicationInsights
                        // or if you want to capture logs from early in the application startup
                        // pipeline from Startup.cs or Program.cs itself.
                        // builder.AddApplicationInsights("0220f791-8d97-401c-9916-164d4481cde9");


                    });
    }
#pragma warning restore CS1591
}
