# Microservice Descriptions 
## Chania

Chania is the main user-facing website of the Heracles Application.  Chania is a dotnet core 3.1 application hosted on Windows App Service.  Chania has its own applications insights instance, and it is this instance that is inspected to get consolidated information from all the microsoervices of the application.  The demo viseos on this site generally use the Chania application insights instance.

The website makes available 12 tiles, each of which represents one of the Labours of Heracles. The following sections describe what happens when a user clicks on a tile:

| Labour | Description |
| --- | ----------- |
| Nemean Lion | This is a very simple labour.  It invokes iraklion/nemean which increments a customer counter (nemean-lionTransactions) and returns "Hello World". |
| Lernaean Hydra | This labour invokes iraklion/lernaean and also increments a custom metric (lernaean-hydraTransactions).  It checks if the current time is between 16:00 and 16:30 and if it is, will eturn an exception inidcating that the service is unavailable.  Otherwise it calculates a delay of x, then sleeps the thread for x milliseconds before returning "Hello from Lernaean Hydra". |
| Ceryneian Hind | This labour invokes thessaloniki/ceryneian and also increments a custom metric (ceryneian-hindTransactions). It always throws an exception whenever its called. |
| Erymanthian Boar | This labour invokes iraklion/erymanthian and also increments a custom metric (erymanthian-boarTransactions). It makes a rest call to https://jsonplaceholder.typicode.com and returns the results. This makes jsonplaceholder.typicode.com and external dependency. |
| Augean Stables| This labour invokes iraklion/augean and also increments a custom metric (augean-stablesTransactions). It uploads a blob to container *augeanblobs* in the iraklion storage account. |
| Stymphalian Birds | This labour invokes iraklion/stymphalian and also increments a custom metric (stymphalian-birdsTransactions). It places a message on a service bus queue which is then processed by the Patra Azure Function.  Patra has its own dedicated application insights instance - which mean you can test correlation in application map across unrelated instances and behind queues. |
| Cretan Bull | This labour invokes iraklion/cretan and also increments a custom metric (cretan-bullTransactions). It places a message on a service bus queue which is then processed by the Ioannina Azure Function.  Ioannina uses the iraklion application insights instance - which mean you can test correlation in application map across the same instance but behind a queue. |
| Mares of Diomedes | This labour involes thessaloniki/diomedes which also increments a custom metric (mares-of-diomedes-bullTransactions).  This labour is very labour intensive.  It creates the database tables if they dont already exist, populates them, then reads from them (allowing you to examine SQL traces) and then runs a private method called DoArtificalWork.  See the source code for full details, but this does different things according to random facotrs and enables you to test the perfromance analysis and performance tracing capabiliites of Application Insights.  Finally, for good measure it also writes a blob to blob storage.|
| Belt of Hippolyta | This labour invokes iraklion/hyppolyta and also increments a custom metric (belt-of-hippolytaTransactions). IF the time is between 8.00-8.30 hyppolyta sleeps for 39 seconds, otherwise it just returns "Hello World from hippolyta!".  This also provides interesting data for performance tracking. |
| Cattle of Geryon | This labour invokes chania/geryon.  This is a secure resource and is protected by an Azure Active directory logon.  This is designed to demonstrate the User tracking and analysis features of Application Insights.  See the dedicated page for the [Cattle of Geryon](cattle-of-geryon.md). |
| Apples of Hesperides | This labour invokes iraklion/hesperides and also increments a custom metric (apples-of-hesperidesTransactions). It also creates a compond metric called HesperidesCount and within that will track succes and failures within two lower level metrics HesperidesSuccess and HesperidesFailure.  If the current second is even HesperidesCount will report success, otherwise it will report failure.  |
| Cerberus | This labour invokes iraklion/cerberus and also increments a custom metric (cerberusTransactions). Dependent on a querystring parameter called cpumax=true, cerberus will also attemot to find the 100000th Prime number.  Otherwise it does nothing. This can be useful for forcing CPU usage to be seen in metrics.|

## Thessaloniki

Thessaloniki is one of two main Apis that provide the functionality for the Chania web site.  Thessaloniki is a dotnet core 3.1 application hosted on Windows App Service, and has its own Application Insights instance.  It hosts 2 main operations (that control the functionality for the Ceryneian Hind and MAres of Diomedes labours) operations. [You can view the swagger for Thessaloniki](https://hercthessaloniki-api.azurewebsites.net/index.html). The SettingsView operation is just a test, and isnt used by the Heracles application.

## Iraklion

Iraklion is the main Apis that provide the functionality for the  Chania web site. Iraklion is a dotnet core 3.1 application hosted on Linux App Service for containers.  It again has its own Application Insights instance, and it hosts the remaining 10 operations for the labours. [You can view the swagger for Iraklion](https://herciraklion-api.azurewebsites.net/index.html). The Azure portal does not support App Insights configuration for App Service for Linux, so the option is greyed out in the portal menu for the iraklion app service.  Howver, you can still see specifics relating to Iraklion by selecting the Ap Insights instance directly.

## Ioaninna

Ioannina is a very simple service that is invoked only when the Cretan Bull labour is executed.  The Cretan operation in the Iraklion api places a message on a service bus queue and messages on this queue trigger an Azure Function within the Ioannina service that processes the message.   *Notice that correlation is maintained even after asynchronous processing via a queue*. Ioannina is interesting in that it shares it's App Insights instance with IRaklion (and uses the Iraklion instance).  Contrast this with Patra below.

## Patra

Patra is a clone of Ioannina, which in this case is invoked by the Stymphalian Birds labour.  The Cretan Stymphalian in the Iraklion api places a message on a service bus queue and messages on this queue trigger an Azure Function within the Patra service that processes the message.  Unlike Ioannina, Patra has it's own App Insights instance with demonstrates that it clearly possible to have multiple App Insights instances (one per micrososervice) and still maintain correlation and end to end traceability.

## Herecles

Heracles is a utility service.  It doesnt play any part in the Labours of Heracles, but it does do some interesting things.  Heracles is an custom Azure Function app.  It's main purpose is to generate traffic periodically, so that at all times there is meaningful data to inspect in all areas of Application Insights.

Probably most importantly there is a TimerTrigger that fires every 5 minutes and generates a random number of calls to random services chosen from the 12 labours.

Additionally, [and subject to additional configuration](configure-ui-generator.md), Heracles can (optionally) generate real user traffic to the Chania site.  It does this using a ChromeDriver headless browser from the [Selenium project](https://github.com/SeleniumHQ).  When configured, this service will run every minute, will logon to the site and randomly choose navigation paths.  This enables us to examine the user tracking and web analytics capabilities withing Application Insights.

> Hercules uses a custom base container image (so that the Selenium components can be installed) and as such needs to run on a Premium function plan - which is quite costly.  IF you are very cost conscious then you may want to delete the Hracles function app and generate traffic manually.
