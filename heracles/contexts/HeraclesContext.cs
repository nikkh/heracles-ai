namespace Heracles
{
    public class HeraclesContext
    {
        public int NumberOfCallsPerInvocation { get; set; }
        public int NumberOfUserJourneys { get; set; }
        public string BaseUrl { get; set; }

        public bool UserSimulationEnabled { get; set; }
        public string UserTestingParametersStorageConnectionString { get; set; }
        public int MinimumThinkTimeInMilliseconds { get; set; }
    }
}
