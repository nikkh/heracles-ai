using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;


namespace Heracles.UI
{
    public class UIControllerTimerTrigger
    {
        private readonly HeraclesContext _heraclesContext;

        public UIControllerTimerTrigger(IConfiguration config, HeraclesContext heraclesContext)
        {
            _heraclesContext = heraclesContext;
        }

        [FunctionName("UIControllerTimerTrigger")]
        public async Task Run([TimerTrigger("0 * * * * *")]TimerInfo myTimer, ILogger log, ExecutionContext ec)
        {
            int numSimulations=0;
            try
            {
                log.LogInformation($"{ec.FunctionName} (timer trigger) function executed at: {DateTime.UtcNow}");
                var worker = new UIControllerWorker(_heraclesContext);
                numSimulations = await worker.Run(log, ec.FunctionName);
                return;
            }
            catch (Exception e)
            {
                log.LogError($"Exeception during execution of {ec.FunctionName}. Message: {e.Message}. Check Inner Exception", e);
                throw e;
            }
        }
       
    }
}
