using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;


namespace Heracles
{
    public class HeraclesGeneratorTimerTrigger
    {
        private readonly HeraclesContext _heraclesContext;

        public HeraclesGeneratorTimerTrigger(IConfiguration config, HeraclesContext heraclesContext)
        {
            _heraclesContext = heraclesContext;
        }

        [FunctionName("ZodiacGeneratorTimerTrigger")]
        public async Task Run([TimerTrigger("0 */5 * * * *")]TimerInfo myTimer, ILogger log, ExecutionContext ec)
        {
            try
            {
                log.LogInformation($"{ec.FunctionName} (timer trigger) function executed at: {DateTime.UtcNow}");
                var worker = new HeraclesGeneratorWorker(_heraclesContext);
                await worker.Run(log, ec.FunctionName);
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
