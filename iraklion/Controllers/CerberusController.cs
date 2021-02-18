﻿using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;

namespace Iraklion.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CerberusController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;
        private readonly IConfiguration _configuration;

        public CerberusController(ILogger<CerberusController> logger, TelemetryClient telemetryClient, IConfiguration configuration)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
            _configuration = configuration;
        }

         
         /// <summary>
         /// This api may or maynot use a lot of CPU... depends on the query string
         /// </summary>
       
        [HttpGet]
        public ActionResult<string> Get(string traceGuid, string cpumax)
        {
            const string controllerName = "cerberus";

            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);
            if (cpumax.ToUpper() == "TRUE")
            {
                _logger.LogWarning($"CPU max is requested");
                long nthPrime = FindPrimeNumber(100000); //set higher value for more time
                return $"cerberus calculated the nthPrime(100000) and the result was {nthPrime}";

            }

            return $"There was nothing for cerberus to do";

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
