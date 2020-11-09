using System;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace Iraklion.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AquariusController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;
        private readonly IConfiguration _configuration;

        public AquariusController(ILogger<AquariusController> logger, TelemetryClient telemetryClient, IConfiguration configuration)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
            _configuration = configuration;
        }

        [HttpGet]
        public ActionResult<string> Get(string traceGuid, string cpumax)
        {
            const string controllerName = "Aquarius";
            
            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);


            Metric compundMetric = _telemetryClient.GetMetric("AquariusCount", "Status");
            var num = DateTime.Now.Second;
            if (num % 2 == 0)
            {
                compundMetric.TrackValue(1, "AquariusSuccess");
                _logger.LogInformation($"Call to Aquarius was pseudo-succesful");
            }
            else
            {
                compundMetric.TrackValue(1, "AquariusFailure");
                _logger.LogInformation($"Call to Aquarius was pseudo-failure");
            }

            return $"Aquarius is done";

        }

        private long FindPrimeNumber(int n)
        {
            int count = 0;
            long a = 2;
            while (count < n)
            {
                long b = 2;
                int prime = 1;// to check if found a prime
                while (b * b <= a)
                {
                    if (a % b == 0)
                    {
                        prime = 0;
                        break;
                    }
                    b++;
                }
                if (prime > 0)
                {
                    count++;
                }
                a++;
            }
            return (--a);
        }

    }
}
