﻿using System;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Thessaloniki.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CeryneianController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;

        public CeryneianController(ILogger<CeryneianController> logger, TelemetryClient telemetryClient)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
        }


        /// <summary>
        /// This api throws an exception
        /// </summary>

        [HttpGet]
        public ActionResult<string> Get(string traceGuid)
        {
            const string controllerName = "ceryneian-hind";

            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);
            try
            {
                throw new Exception("Exception thrown intentionally");
            }
            catch (Exception e)
            {
                _telemetryClient.TrackException(e);
                throw;
            }
        }

       

    }
}
