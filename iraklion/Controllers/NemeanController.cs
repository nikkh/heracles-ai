using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Iraklion.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NemeanController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;

        public NemeanController(ILogger<NemeanController> logger, TelemetryClient telemetryClient)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
        }

         
         /// <summary>
         /// Very simple API.  Just returns Hello World.  Also logs error, warning, infomration, debug and trace output
         /// </summary>
         /// <returns>a string containing hello world</returns>
        [HttpGet]
        public ActionResult<string> Get(string traceGuid)
        {
            const string controllerName = "nemean-lion";

            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);
            return "Hello World from Nemean!";
        }

       

    }
}
