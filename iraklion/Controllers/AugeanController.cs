using System;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using Azure.Storage.Blobs;
using System.IO;
using System.Text;
using Azure;

namespace Iraklion.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AugeanController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly TelemetryClient _telemetryClient;
        private readonly IConfiguration _configuration;

        public AugeanController(ILogger<AugeanController> logger, TelemetryClient telemetryClient, IConfiguration configuration)
        {
            _logger = logger;
            _telemetryClient = telemetryClient;
            _configuration = configuration;
        }

         
         /// <summary>
         /// This api returns a random list of posts in lorem ipsum, obtained form a third party web service
         /// </summary>
       
        [HttpGet]
        public async Task<ActionResult<string>> Get(string traceGuid)
        {
            const string controllerName = "augean-stables";

            var metricName = $"{controllerName}Transactions";
            var message = $"{controllerName} has been invoked. TraceGuid={traceGuid}";
            _telemetryClient.TrackEvent(message);
            _telemetryClient.GetMetric(metricName).TrackValue(1);
            _logger.LogInformation(message);
            var storageConnectionString = _configuration["Azure:Storage:ConnectionString"];
            // Create a BlobServiceClient object which will be used to create a container client
            BlobServiceClient blobServiceClient = new BlobServiceClient(storageConnectionString);

            //Create a unique name for the container
            string containerName = "augeanblobs";

            // Dont know whats happened to CreateIfNotExists in the API?
            BlobContainerClient containerClient = null;
            try
            {
                containerClient = await blobServiceClient.CreateBlobContainerAsync(containerName);
                _logger.LogInformation($"Container {containerName} was created.");
            }
            catch (RequestFailedException)
            {
                containerClient = blobServiceClient.GetBlobContainerClient(containerName);
                _logger.LogInformation($"Container {containerName} already exists.");
            }
            string blobName = $"blob{System.DateTime.Now.Ticks.ToString()}";
            BlobClient blobClient = containerClient.GetBlobClient(blobName);

            string blobContents = $"Blob {blobName} created by augean-stables {System.DateTime.Now.ToLongDateString()}\n";

            
            Byte[] byteArray = Encoding.ASCII.GetBytes(blobContents);
            using (MemoryStream stream = new MemoryStream(byteArray))
            {
                await blobClient.UploadAsync(stream);
                stream.Close(); ;
            }
            _logger.LogInformation($"Blob {blobName} was created at {blobClient.Uri.ToString()}.");
            return blobClient.Uri.ToString();

        }

       

    }
}
