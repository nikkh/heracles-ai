using System;
using System.Threading;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Chania.Controllers
{
    [Authorize]
    public class GeryonController : Controller
    {
        private readonly ILogger<GeryonController> logger;
        private readonly IConfiguration config;
        private readonly TelemetryClient telemetryClient;

        public GeryonController(ILogger<GeryonController> logger, IConfiguration configuration, TelemetryClient telemetryClient)
        {
            this.logger = logger;
            this.config = configuration;
            this.telemetryClient = telemetryClient;
        }
        public IActionResult Index()
        {
            ViewBag.AppInsightsKey = config["ApplicationInsights:InstrumentationKey"];
            return View();
        }

        public IActionResult Go()
        {
            
            return View();
        }
        public IActionResult redroute()
        {

            return View();
        }
        public IActionResult blueroute()
        {

            return View();
        }
        public IActionResult greenroute()
        {

            return View();
        }
        public IActionResult rainbowroute()
        {

            return View();
        }
        public IActionResult redstepa()
        {

            return View();
        }
        public IActionResult redstepb()
        {

            return View();
        }
        public IActionResult bluestepa()
        {

            return View();
        }
        public IActionResult bluestepb()
        {

            return View();
        }
        public IActionResult greenstepa()
        {

            return View();
        }
        public IActionResult greenstepb()
        {
            Thread.Sleep(3000);
            return View();
        }
        public IActionResult rainbowstepa()
        {

            return View();
        }
        public IActionResult rainbowstepb()
        {

            return View();
        }
        public IActionResult victoryshortcut()
        {

            return View();
        }
        public IActionResult chance()
        {
            ViewBag.Proceed = false;
            Random r = new Random();
            int result = r.Next(1,100);
            if (result > 77) ViewBag.Proceed = true;
            return View();
        }
        public IActionResult victory()
        {

            return View();
        }
    }
}
