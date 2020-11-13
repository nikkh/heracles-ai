using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace Heracles.UI
{
    public class UIControllerHttpTrigger
    {
        private readonly HeraclesContext _heraclesContext;
        public UIControllerHttpTrigger(IConfiguration config, HeraclesContext heraclesContext)
        {
            _heraclesContext = heraclesContext;
        }

        [FunctionName("UIControllerHttpTrigger")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext ec)
        {
            log.LogInformation($"{ec.FunctionName} (http trigger) function executed at: {DateTime.UtcNow}");
            int numSimulations;
            var worker = new UIControllerWorker(_heraclesContext);
            try
            {
                if (Int32.TryParse(req.Query["NumberOfSimulations"], out int numRequests))
                {
                    numSimulations = await worker.Run(log, ec.FunctionName, numRequests);
                }
                else
                {
                    numSimulations = await worker.Run(log, ec.FunctionName);
                }
            }
            catch (Exception e)
            {
                log.LogError($"Exeception during execution of {ec.FunctionName}. Message: {e.Message}. Check Inner Exception", e);
                return new StatusCodeResult(500);
            }
            var responseMessage = $"{ec.FunctionName} performed {numSimulations} simulations";
            return new OkObjectResult(responseMessage);
        }
    }
}
