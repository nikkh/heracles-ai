using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Newtonsoft.Json;
using System.Threading.Tasks;

namespace Heracles.UI
{
    class UIControllerUtil
    {

        private readonly HeraclesContext _heraclesContext;
        private static CloudStorageAccount cloudStorageAccount;

        internal UIControllerUtil(HeraclesContext heraclesContext)
        {
            _heraclesContext = heraclesContext;
            if (cloudStorageAccount == null) cloudStorageAccount = CloudStorageAccount.Parse(_heraclesContext.UserTestingParametersStorageConnectionString);
        }

        internal async Task<UIParameters> GetParameters(ILogger log)
        {
            CloudBlobClient blobClient = cloudStorageAccount.CreateCloudBlobClient();
            // TODO Remove these hard coded references
            CloudBlobContainer container = blobClient.GetContainerReference("zodiac-generator-config");
            var dllBlob = container.GetBlockBlobReference("GeneratorParameters.json");

            var parametersAsString = await dllBlob.DownloadTextAsync();
            var parameters = JsonConvert.DeserializeObject<UIParameters>(parametersAsString);
            return parameters;
        }

        internal bool UserSimulationEnabled(ILogger log = null)
        {
            if (_heraclesContext.UserSimulationEnabled)
            {
                if (log != null) log.LogInformation($"This function will simulate user traffic if specified in configuration.  Current state is enabled");
                return true;
            }
            else
            {
                if (log != null) log.LogWarning($"This function will simulate user traffic if specified in configuration.  Current state is disabled");
                return false;
            }
        }

    }
}
