# Manually Trigger Heracles Generator

In order to do this, you issue a GET request from your browser to the function app url, the generator function will geenrate the 'NumberOf' specified in the url. You can change the 'number of' to suit your needs.

So let’s compose this url:
1.	First get the function app url from the Overview page of the function app. It will be something like `https://<your-alias>herecles-gen-func.azurewebsites.net/`
1.	Second get the security code. The function security code means that only people who know this code can call your generator function.  To find the code, open the <your-alias>heracles-rg Resource group in the azure portal, and select the <your-alias>herecles-gen-func azure function.  
1.  Select the Functions option in the left-nav menu
2.  Choose the HeraclesGeneratorHttpTrigger or UIControllerHttpTrigger function in the centre pane
3.  In the left menu select Function Keys and press the little 'eye' symbol to reveal the key.
4.  Copy the value for the default key

You can now construct your request url:

`https://<your-alias>hercles-gen-func.azurewebsites.net/api/HeraclesGeneratorHttpTrigger?code=<your-key>&NumberOfCalls=30` or
`https://<your-alias>hercles-gen-func.azurewebsites.net/api/UIControllerHttpTrigger?code=<your-key>&NumberOfSimulationss=3`
  
Paste these urls into your browser and press enter.  After a little while, you should see a success message "HeraclesGenerator generated 30 requests". You can add the result page to browser favourites and generate traffic at the 'touch of a button'.
