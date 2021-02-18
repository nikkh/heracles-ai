# Diagnose an Exception

This activity is designed to help you find your way around Application Insights.  Imagine we have just made a deployment of our application to a staging site, and we want to direct a small amount of user traffic to that site so we can check the behaviour of the release before rolling it out more widely.
 
Well actually, we have just deployed our application – let’s have a look at how its behaving.  First, we need to make sure we have some traffic to our site.  In order to do this, you can use the Heracles Generator function app to generate some requests. When you issue a GET request from your browser to the function app url, the generator function generate NumberOfCalls transactions on your chania-web site.  You can change number of calls to suit your needs in the url parameter.

[Trigger Heracles to generate requests](heracles-generator.md)

So let’s compose this url:
1.	First get the function app url from the Overview page of the function app. It will be something like `https://<your-alias>herecles-gen-func.azurewebsites.net/`
1.	Second get the security code. The function security code means that only people who know this code can call your generator function.  To find the code, open the <your-alias>heracles-rg Resource group in the azure portal, and select the <your-alias>herecles-gen-func azure function.  
1.  Select the Functions option in the left-nav menu
2.  Choose the HeraclesGeneratorHttpTrigger function in the centre pane
3.  In the left menu select Function Keys and press the little 'eye' symbol to reveal the key.
4.  Copy the value for the default key

You can now construct your request url:

`https://<your-alias>hercles-gen-func.azurewebsites.net/api/HeraclesGeneratorHttpTrigger?code=<your-key>&NumberOfCalls=30`
  
Paste this url into your browser and press enter.  After a little while, you should see a success message "HeraclesGenerator generated 30 requests". Keep this browser window open.

Open the Application Insights instance for chania-web, and choose Live Metrics.  Whlie watching the Live Metrics screen, Press enter on the generator browser again.  Now you should see transaction being gerated and their processing should appear in the Live Metrics window.  Keep pressing enter on the gerator until you have seen at least one exception in the Sample Telemetry windows in Live Metrics.

This is simulating what we might see if we were looking at Live MEtrics during a blue-green or canary release to our production environment.  And we  have just seen an exception!  At this point we would point all our traffic back tot he previous version of our site and we can now diagnose the exceptions, comfortable in the knowledge that our Live site is still functioning.

In the menu for chania-web application insights, choose Exceptions.

## The challenge

1. Which Labour of Heracles generated the most exceptions during our test?
1. Which line of code is at fault and casuing these exceptions?

[Check your answers...](diagnose-exception-answer.md)

 
