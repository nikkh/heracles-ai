# Azure Active Directory (AAD) Configuration

AAD configuration is optional for using Heracles.  One of the labours *Cattle of Geryon* requires an authenticated user.  There is also a capability to automatically generate user traffic (and this also uses *Cattle of Geryon*).

In a standard deployment, the application is configured to access Nick's active directory xekina.onmicrosoft.com, but since you dont know the users or passwords in that directory, you will need to change the configuration to point at your own AAD.

You dont need to be a global administrator to complete this configuration, but you will need to be a member of the Application administrator role. You should choose (or create) and AAD where you have these permissions and you can also create users that dont require MFA (requiring MFA won't work for unattended logons).

There are four steps to configuration:

- Configure an AAD application to represent the <your-alias>chania-web application
- Create some test users in AAD.
- Configure your test users in heracles-gen-func
- Configure chania-web to use the your AAD

These steps are described in detail in the following sections:

## Configure an AAD application

The Client AAD Application represents the identity of the <your-alias>chania-web application.  Configuration in this application points to this AAD application which is then used to represent the client applications in scenarios for authentication, consent and authorization. You can see your registrations in the [Azure portal](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/RegisteredApps). If you have more than one directory, then make sure you switch to the tenant that you want to use. 

### Creating the basic application

Choose the '+ new registration' button at the top of the screen.

1. Choose a name for this application.  (<your-alias>chania-web would work)
1. Choose 'Accounts in this organizational directory only'.  There's no reason why the other options wouldnt work - but I havent tested them.
1. Choose 'Register'

This has created a shell application without much detail.  We'll fill in the detail shortly, but for now make a note of some items.  We're going to need to update the <your-alias>chania-web with these values, so I will use the neames of the configuration items to make it easier.

>AzureAD__ClientId = Application (client) ID

### Creating a secret

Next we need to generate a secret.  Choose 'Certificates & secrets' from the left nav. Under 'Client secrets' click '+ New client secret'.  Give it a name (main would work), and leave expiry at 1 year.  Click 'Add'. You will see that a new secret value is generated an made available to copy in the value column.  Copy the value (if you navigate away before copying, you'll need to repeat the process).

>AzureAD__ClientSecret = the value you just copied

### Reply Urls

You'll need to add the url of your chania application to the reply urls for AAD application.  the full url should be `https://<your-alias>chania-web.azurewebsites.net/signin-oidc`.  This means that the url of you application is trusted by AAD as a location where tokens may be returned.

## Create some test users in AAD.

[Create some users](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/add-users-azure-active-directory) in AAD.  Logon to each user in turn and change the password - note down the emails ddress and password for at least two users. Logon to your https://<your-alias>chania-web.azurewebsites.net application as one of these users to prove it works.


## Configure your test users in heracles-gen-func

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

Heracles will read this file whenever one of the UIController trigger fires, and will generate the required number of user journey's for one of the users defined in this file.

You will need to ensure the users (and their passwords) in this file match users in your active directory.  You can add additional users, and additional journeys - the steps contain the #ids of elements on screen to click in the user journey.

## Configure chania-web to use the your AAD

> You will need the valaues you noted for *AzureAD__ClientId* and *AzureAD__ClientSecret* earlier on this page.

In the Azure portal, access the configuration blade for the <your-alias>chania-web app service.  replace the settings identified above witht he values you noted.  Also change the value of *AzureAD__Domain* to be the domain of your AAD (e.g. xekina.onmicrosoft.com).
