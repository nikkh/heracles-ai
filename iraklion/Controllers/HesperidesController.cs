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
    public class HesperidesController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;
        private readonly IConfiguration _configuration;

        public HesperidesController(ILogger<HesperidesController> logger, TelemetryClient telemetryClient, IConfiguration configuration)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
            _configuration = configuration;
        }

        [HttpGet]
        public ActionResult<string> Get(string traceGuid, string cpumax)
        {
            const string controllerName = "apples-of-hesperides";
            
            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);


            Metric compundMetric = _telemetryClient.GetMetric("HesperidesCount", "Status");
            var num = DateTime.Now.Second;
            if (num % 2 == 0)
            {
                compundMetric.TrackValue(1, "HesperidesSuccess");
                _logger.LogInformation($"Call to Hesperides was pseudo-succesful");
            }
            else
            {
                compundMetric.TrackValue(1, "HesperidesFailure");
                _logger.LogInformation($"Call to Hesperides was pseudo-failure");
            }

            return $"Hesperides is done";

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
