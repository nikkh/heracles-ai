# User Traffic

Application Insights has sophiticated Uer Tracking and Analysis, similar to Google Analytics.  In order to always have a 'fresh supply' of users using your site, Heracles will generate syntehtic user traffic, for authenticated users.

It does this using ChromeDriver, part of the Selenium Nuget packages, that are often used for automated testing.  All data generation occurs in an Azure Function called <your-alias>heracles-gen-func:
  
![a screenshot of a function app](../images/hercheracles-functionapp.jpg)

The two functions we are interested in are:

- UIControllerHttpTrigger
- UIControllerTimerTrigger

UIControllerTimerTrigger fires every 10 minutes and geenrates a random number of user journeys, for a random set of users.  This gives consistent but different monitoring every time, similar enought that you can learn, but different enough to provide variety in what we see.

You can also [manually trigger a generation](manually-trigger-generation.md) run using a browser.

## Configuration Notes

> This functionality is disabled by default.  Once you are happy with your [Active Directory configuration](active-directory-configuration.md) and the contents of GeneratorParameters.json you can enable it by changing configuration setting `HeraclesContext__UserSimulationEnabled` for the <your-alias>heracles-gen-func functionapp to true. 

When Heracles is deployed, a storage account is created in the <your-alias>heracles-rg resource group.  With that storage account is a container called *zodiac-generator-config* containing a file *GeneratorParameters.json*.  User simulation is controlled using the parameters in this file:
  
  `{
      "Users": [
          {"Id": "joao@xekina.onmicrosoft.com", "Password": "redacted"},
          {"Id": "neves@xekina.onmicrosoft.com","Password": "redacted"}
       ],
       "Sessions": [
       {"Steps": ["geryon-go-red", "cap021", "cap023", "cap024" ] }, 
       { "Steps": [ "geryon-go-rainbow", "cap013", "cap019", "cap006" ] },
       { "Steps": [ "geryon-go-blue", "cap003" ] }]
   }
`

Heracles will read this file whenever one of the UIController trigger fires, and will generate the required number of user journey's for one of th eusers defined in this file.

You will need to ensure the users (and their passwords) in this file match users in your active directory.  You can add additional users, and additional journeys - the steps contain the #ids of elemets on screen to click in the user journey.
