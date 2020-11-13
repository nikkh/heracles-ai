using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Chania.Models;
using Chania.Utils;
using Microsoft.AspNetCore.Hosting;

namespace Chania.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IConfiguration _configuration;
        private readonly string _iraklionBaseUrl;
        private readonly string _thessalonikiBaseUrl;
        const string iraklionUrlKey = "IraklionBaseUrl";
        const string scorpioUrlKey = "ThessalonikiBaseUrl";
        private readonly TelemetryClient _telemetryClient;
        private readonly IWebHostEnvironment _hostingEnvironment;

        public HomeController(ILogger<HomeController> logger, IConfiguration configuration, TelemetryClient telemetryClient, IWebHostEnvironment hostingEnvironment)
        {
            _logger = logger;
            _configuration = configuration;
            _iraklionBaseUrl = _configuration[iraklionUrlKey];
            _thessalonikiBaseUrl = _configuration[scorpioUrlKey];
            _telemetryClient = telemetryClient;
            _hostingEnvironment = hostingEnvironment;
        }

        private string GetTechnicalDescription(string itemName) 
        {
            
            try
            {
                var content = System.IO.File.ReadAllText($"{_hostingEnvironment.WebRootPath}//TechnicalDescriptions/{itemName}.html");
                return content;
            }
            catch (Exception e)
            {
                _logger.LogError(e.ToString());
                return $"No technical description has yet been authored for {itemName}";
            }

        }

        public IActionResult Index()
        {
            ViewData["Title"] = "Home Page";
            var vm = new IndexViewModel();
            vm.Signs.Add("nemean-lion", new SignPartialViewModel { Name = "nemean-lion", 
                FriendlyName= "Nemean Lion",
                Description = "If Heracles slew the Nemean lion and returned alive within 30 days, the town would sacrifice a lion to Zeus, but if he did not a boy would sacrifice himself to Zeus. ",
                TechnicalDescription = GetTechnicalDescription("nemean-lion"),
                Image = "/images/nemean-lion.jpg"
            });
            vm.Signs.Add("lernaean-hydra", new SignPartialViewModel { Name = "lernaean-hydra",
                FriendlyName = "Lernaean Hydra",
                Description = "Heracles fired flaming arrows into the Hydra's lair and confronted the Hydra, wielding a harvesting sickle. Upon cutting off each of its heads he found that two grew back.",
                TechnicalDescription = GetTechnicalDescription("lernaean-hydra"),
                Image = "/images/lernaean-hydra.jpg"
            }); ;
           
            vm.Signs.Add("ceryneian-hind", new SignPartialViewModel { Name = "ceryneian-hind",
                FriendlyName = "Ceryneian Hind",
                Description = "The Ceryneian Hind was so fast that it could outrun an arrow. Heracles chased it on foot for a full year.  He eventually trapped it with an arrow between its forelegs.",
                TechnicalDescription = GetTechnicalDescription("ceryneian-hind"),
                Image = "/images/ceryneian-hind.jpg"
            }) ;

            vm.Signs.Add("erymanthian-boar", new SignPartialViewModel { Name = "erymanthian-boar",
                Description = "Hercules was able to drive the fearful boar into snow where he captured the boar in a net and brought the boar to Eurystheus",
                FriendlyName = "Erymanthian Boar",
                TechnicalDescription = GetTechnicalDescription("erymanthian-boar"),
                Image = "/images/erymanthian-boar.jpg"
            });

            vm.Signs.Add("augean-stables", new SignPartialViewModel { Name = "augean-stables",
                Description = "King Augeas had a stable which housed over 1,000 cattle. Hercules approached King Augeas and offered to clean the stables in one day and asked for a tenth of his cattle in return",
                FriendlyName = "Augean Stables",
                TechnicalDescription = GetTechnicalDescription("augean-stables"),
                Image = "/images/augean-stables.jpg"
            });

            vm.Signs.Add("stymphalian-birds", new SignPartialViewModel { Name = "stymphalian-birds",
                Description = "The birds were fierce man-eaters. Athena gave Hercules clapper to help him scare the birds. As the birds flew, Hercules shot them with his bow and arrow. Easy.",
                FriendlyName = "Stymphalian Birds",
                TechnicalDescription = GetTechnicalDescription("stymphalian-birds"),
                Image = "/images/stymphalian-birds.jpg"
            });

            vm.Signs.Add("cretan-bull", new SignPartialViewModel { Name = "cretan-bull",
                Description = "This bull was destroying the city and scaring the residents. King Minos granted Hercules permission to take this bull away.  Hercules wrestled the bull to the ground and took to Eurystheus.",
                FriendlyName = "Cretan Bull",
                TechnicalDescription = GetTechnicalDescription("cretan-bull"),
                Image = "/images/cretan-bull.jpg"
            });

            vm.Signs.Add("mares-of-diomedes", new SignPartialViewModel { Name = "mares-of-diomedes",
                Description = "King Diomedes of Thrace trained mares in his village to eat human flesh. Hercules would kill King Diomedes, feed the horses to calm them, and bring the horses back to Eurystheus.",
                FriendlyName = "Mares of Diomedes",
                TechnicalDescription = GetTechnicalDescription("mares-of-diomedes"),
                Image = " /images/mares-of-diomedes.jpg"
            });


            vm.Signs.Add("belt-of-hippolyta", new SignPartialViewModel { Name = "belt-of-hippolyta",
                Description = "Hercules told Hippolyta that he needed her belt to take back to Eurystheus. Hippolyta agreed to let Hercules have the belt. Hercules killed Hippolyta and returned with her belt.",
                FriendlyName = "Belt of Hippolyta",
                TechnicalDescription = GetTechnicalDescription("belt-of-hippolyta"),
                Image = "/images/belt-of-hippolyta.jpg"
            });

            vm.Signs.Add("cattle-of-geryon", new SignPartialViewModel { Name = "cattle-of-geryon",
                Description = "Hercules travelled to Erytheia to retrieve the cattle. Along his way, he killed many beasts.  Hercules finally gathered the herd and took them to Eurystheus who sacrificed the herd of cattle to Hera.",
                FriendlyName = "Cattle of Geryon",
                TechnicalDescription = GetTechnicalDescription("cattle-of-geryon"),
                Image = "/images/cattle-of-geryon.jpg"
            });

            vm.Signs.Add("apples-of-hesperides", new SignPartialViewModel { Name = "apples-of-hesperides",
                Description = "Hercules held up the heavens and earth while Atlas stole the apples. Atlas wanted to take the apples to Eurystheus, and Hercules agreed.  He then he asked Atlas to hold the heavens and earth while he adjusted his garments, but Hercules left and returned to Eurystheus to deliver the golden apples.",
                FriendlyName = "Apples of Hesperides",
                TechnicalDescription = GetTechnicalDescription("apples-of-hesperides"),
                Image = "/images/apples-of-hesperides.jpg"
            });

            vm.Signs.Add("cerberus", new SignPartialViewModel { Name = "cerberus",
                Description = "Hercules battled many beasts and monsters throughout the underworld until he reached Hades. Hercules asked Hades if he could take the Cerberus to the surface. Hades agreed, only if Hercules could restrain the beat with his bare hands and no weapons.",
                FriendlyName = "Cerberus",
                TechnicalDescription = GetTechnicalDescription("cerberus"),
                Image = "/images/cerberus.jpg"
            });
            return View(vm);
        }

        public IActionResult Privacy()
        {
            
            return View();
        }

    
        #region labours
        [HttpGet, ActionName("mares-of-diomedes")]
        public async Task<IActionResult> maresofdiomedes()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "mares-of-diomedes" };
            vm.ResponseData = await CallRestApi(_thessalonikiBaseUrl, $"api/diomedes?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("nemean-lion")]
        public async Task<IActionResult> nemeanlion()
        {

            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "nemean-lion" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/nemean?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }

        [HttpGet, ActionName("cretan-bull")]
        public async Task<IActionResult> cretanbull()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "cretan-bull" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/cretan?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }

        [HttpGet, ActionName("cattle-of-geryon")]
        public IActionResult cattleofgeryon()
        {
            var traceGuid = Guid.NewGuid().ToString();
            return RedirectToAction("Index", "Geryon");
           
        }

        [HttpGet, ActionName("belt-of-hippolyta")]
        public async Task<IActionResult> beltofhyppolyta()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "belt-of-hippolyta" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/hippolyta?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("apples-of-hesperides")]
        public async Task<IActionResult> applesofhesperides()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "apples-of-hesperides" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/hesperides?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("lernaean-hydra")]
        public async Task<IActionResult> lerneanhydra()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "leranaean-hydra" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/lernaean?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("ceryneian-hind")]
        public async Task<IActionResult> ceryneianhind()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "ceryneian-hind" };
            vm.ResponseData = await CallRestApi(_thessalonikiBaseUrl, $"api/ceryneian?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("erymanthian-boar")]
        public async Task<IActionResult> erymanthianboar()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "erymanthian-boar" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/erymanthian?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("stymphalian-birds")]
        public async Task<IActionResult> stymphalianbirds()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "stymphalian-birds" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/stymphalian?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }
        [HttpGet, ActionName("augean-stables")]
        public async Task<IActionResult> augeanstables()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "augean-stables" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/augean?traceGuid={traceGuid}");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }

        [HttpGet, ActionName("cerberus")]
        public async Task<IActionResult> cerberus()
        {
            var traceGuid = Guid.NewGuid().ToString();
            var vm = new GenericViewModel { LabourName = "cerberus" };
            vm.ResponseData = await CallRestApi(_iraklionBaseUrl, $"api/cerberus?traceGuid={traceGuid}&cpumax=false");
            vm.TraceGuid = traceGuid;
            return View("GenericResult", vm);
        }



        #endregion



        private async Task<string> CallRestApi(string _baseUrl, string api)
        {
            string content = "";
            using (var client = new HttpClient())
            {
                //Passing service base url  
                client.BaseAddress = new Uri(_baseUrl);
                // client.DefaultRequestHeaders.Clear();
                //Define request data format  
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                //Sending request to find web api REST service resource GetAllEmployees using HttpClient  
                HttpResponseMessage response = await client.GetAsync(api);
                
                //Checking the response is successful or not which is sent using HttpClient  
                if (response.IsSuccessStatusCode)
                {
                    //Storing the response details recieved from web api   
                    content = response.Content.ReadAsStringAsync().Result;
                }
                else 
                {
                    throw new Exception($"Call to Restful service {_baseUrl}{api} failed. {response.StatusCode.ToString()}");
                }
                return content;
            }
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
    class Parameters
    {
        public string Operation { get; internal set; }
        public string Url { get; internal set; }
    }
}
