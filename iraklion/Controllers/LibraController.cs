using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Iraklion.Utils;
using Microsoft.Extensions.Configuration;
using Heracles.Common;

namespace Iraklion.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LibraController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;
        private readonly ServiceBusSender _serviceBusSender;
        private readonly IConfiguration _configuration;

        public LibraController(ILogger<LibraController> logger, TelemetryClient telemetryClient, IConfiguration configuration, ServiceBusSender serviceBusSender)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
            _configuration = configuration;
            _serviceBusSender = serviceBusSender;
        }

         
         /// <summary>
         /// This api returns a random list of posts in lorem ipsum, obtained form a third party web service
         /// </summary>
       
        [HttpGet]
        public async Task<ActionResult<string>> Get(string traceGuid)
        {
            const string controllerName = "Libra";

            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);
            var payload = $"This is a message sent from Libra on {System.DateTime.Now.ToShortDateString()} at {System.DateTime.Now.ToLongTimeString()}.  TraceGuid={traceGuid}";
            var messageModel = new MessageModel();
            messageModel.Payload = payload;
            messageModel.TraceGuid = traceGuid;
            messageModel.Queue = "libra-queue";
            await _serviceBusSender.SendMessage(messageModel);
            return payload;

        }

       

    }
}
