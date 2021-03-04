#!/bin/bash -e
output_blob=$OUTPUT_LOG_NAME
echo "<h2>Chania Infrastructure</h2>" >> $output_blob
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo         Deploying chania
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ---Global Variables
echo "CHANIA_ALIAS: $CHANIA_ALIAS"
echo "HERACLES_LOCATION: $HERACLES_LOCATION"
echo "DB_ADMIN_USER: $DB_ADMIN_USER"
echo "<p>DB_ADMIN_PASSWORD: $DB_ADMIN_PASSWORD</P>" >> $output_blob
echo "IRAKLION_ALIAS: $IRAKLION_ALIAS"
echo "THESSALONIKI_ALIAS: $THESSALONIKI_ALIAS"
echo
# set local variables
appservice_webapp_sku="S1 Standard"
database_edition="Basic"
echo ---Local Variables
echo "App service Sku: $appservice_webapp_sku"
echo "Database Edition: $database_edition"
echo 
# Derive as many variables as possible
applicationName="${CHANIA_ALIAS}"
webAppName="${applicationName}-web"
hostingPlanName="${applicationName}-plan"
dbServerName="${applicationName}-db-server"
dbName="${applicationName}-web-db"
if [ "$HERACLES_SINGLE_RG_NAME" ]; then 
 echo "Deployment will be to a single resource group: $HERACLES_SINGLE_RG_NAME" 
 resourceGroupName="$HERACLES_SINGLE_RG_NAME" 
else
 echo "Deployment will be to multiple resource groups" 
 resourceGroupName="${applicationName}-rg" 
fi

iraklionBaseUrl="https://${IRAKLION_ALIAS}-api.azurewebsites.net/"
thessalonikiBaseUrl="https://${THESSALONIKI_ALIAS}-api.azurewebsites.net/"


echo ---Derived Variables
echo "Application Name: $applicationName"
echo "Resource Group Name: $resourceGroupName"
echo "Web App Name: $webAppName"
echo "Hosting Plan: $hostingPlanName"
echo "DB Server Name: $dbServerName"
echo "DB Name: $dbName"
echo "iraklion base url: $iraklionBaseUrl"
echo "thessaloniki base url: $thessalonikiBaseUrl"
echo

echo "Creating resource group $resourceGroupName in $HERACLES_LOCATION"
az group create -l "$HERACLES_LOCATION" --n "$resourceGroupName" --tags  HeraclesInstance=$HERACLES_INSTANCE Application=heracles MicrososerviceName=chania MicroserviceID=$applicationName PendingDelete=true >> $output_blob
echo "<p>Resource Group: $resourceGroupName</p>" >> $output_blob

echo "Creating Azure Sql Resources in $HERACLES_LOCATION"
echo "<h1>Azure Sql Server: $dbServerName</h1>" >> $output_blob
az sql server create -n $dbServerName -g $resourceGroupName -l $HERACLES_LOCATION -u $DB_ADMIN_USER -p $DB_ADMIN_PASSWORD >> $output_blob
az sql server firewall-rule create -g $resourceGroupName -s $dbServerName -n AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 >> $output_blob
az sql db create -g $resourceGroupName -s $dbServerName -n $dbName --service-objective S0 >> $output_blob
baseDbConnectionString=$(az sql db show-connection-string -c ado.net -s $dbServerName -n $dbName -o tsv)
dbConnectionStringWithUser="${baseDbConnectionString/<username>/$DB_ADMIN_USER}"
sqlConnectionString="${dbConnectionStringWithUser/<password>/$DB_ADMIN_PASSWORD}"
echo "<p>Sqlq Connection String=$sqlConnectionString</p>" >> $output_blob


echo "Creating app service hosting plan $hostingPlanName in group $resourceGroupName"
echo "<h1>Hosting Plan: $hostingPlanName</h1>" >> $output_blob
az appservice plan create -g $resourceGroupName --name $hostingPlanName --location $HERACLES_LOCATION --number-of-workers 1 --is-linux --sku S1 >> $output_blob

echo "Creating app insights component $webAppName in group $resourceGroupName"
echo "<h1>Application Insights: $webAppName</h1>" >> $output_blob
az monitor app-insights component create --app $webAppName --location $HERACLES_LOCATION --kind web -g $resourceGroupName --application-type web >> $output_blob
chaniaAIKey=$(az monitor app-insights component show --app $webAppName -g $resourceGroupName --query instrumentationKey -o tsv)

echo "Creating app service for web site $webAppName in group $resourceGroupName"
echo "<h1>App Service (Web App): $webAppName</h1>" >> $output_blob

az webapp create \
  --name $webAppName \
  --plan $hostingPlanName \
  --resource-group $resourceGroupName \
  --runtime  "DOTNETCORE|3.1" \
   >> $output_blob

echo "<p>App Service (Web App): $webAppName</p>" >> $output_blob

# Attempt to get App Insights configured without the need for the portal
APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$chaniaAIKey;"
APPINSIGHTS_INSTRUMENTATIONKEY=$chaniaAIKey
ApplicationInsightsAgent_EXTENSION_VERSION='~2'

echo "Updating App Settings for $webAppName"
echo "<p>Web App Settings:" >> $output_blob
az webapp config appsettings set -g $resourceGroupName -n $webAppName --settings IraklionBaseUrl=$iraklionBaseUrl ThessalonikiBaseUrl=$thessalonikiBaseUrl ASPNETCORE_ENVIRONMENT=Development AzureAD__Domain=$AAD_DOMAIN AzureAD__TenantId=$AAD_TENANTID AzureAD__ClientId=$AAD_CLIENTID APPLICATIONINSIGHTS_CONNECTION_STRING=$APPLICATIONINSIGHTS_CONNECTION_STRING APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATIONKEY ApplicationInsightsAgent_EXTENSION_VERSION=$ApplicationInsightsAgent_EXTENSION_VERSION >> $output_blob

echo "<p>Availability Test:" >> $output_blob
az group deployment create -g $resourceGroupName --template-file deployment-scripts/chania-webtest.json --parameters webSiteName=$webAppName aiName=$webAppName >> $output_blob
echo "</p>" >> $output_blob
if [ "$HERACLES_OUTPUT_LOGGING" = TRUE ]; then
 cat $output_blob
fi