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
echo "DB_ADMIN_PASSWORD: $DB_ADMIN_PASSWORD" 
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
resourceGroupName="${applicationName}-rg"
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

echo "Creating app service $webAppName in group $resourceGroupName"
 az group deployment create -g $resourceGroupName \
    --template-file chania/chania.json  \
    --parameters webAppName=$webAppName hostingPlanName=$hostingPlanName appInsightsLocation=$HERACLES_LOCATION \
        databaseServerName=$dbServerName databaseUsername=$DB_ADMIN_USER databasePassword=$DB_ADMIN_PASSWORD databaseLocation=$HERACLES_LOCATION \
        databaseName=$dbName \
        sku="${appservice_webapp_sku}" databaseEdition=$database_edition >> $output_blob
echo "<p>App Service (Web App): $webAppName</p>" >> $output_blob

# chania application insights info
chaniaAIKey=$(az monitor app-insights component show --app $webAppName -g $resourceGroupName --query instrumentationKey -o tsv)
# Attempt to get App Insights configured without the need for the portal
APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$chaniaAIKey;"
APPINSIGHTS_INSTRUMENTATIONKEY=$chaniaAIKey
ApplicationInsightsAgent_EXTENSION_VERSION='~2'

echo "Updating App Settings for $webAppName"
echo "<p>Web App Settings:" >> $output_blob
 az webapp config appsettings set -g $resourceGroupName -n $webAppName --settings IraklionBaseUrl=$iraklionBaseUrl ThessalonikiBaseUrl=$thessalonikiBaseUrl ASPNETCORE_ENVIRONMENT=Development AzureAD__Domain=$AAD_DOMAIN AzureAD__TenantId=$AAD_TENANTID AzureAD__ClientId=$AAD_CLIENTID APPLICATIONINSIGHTS_CONNECTION_STRING=$APPLICATIONINSIGHTS_CONNECTION_STRING APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATIONKEY ApplicationInsightsAgent_EXTENSION_VERSION=$ApplicationInsightsAgent_EXTENSION_VERSION >> $output_blob
echo "</p>" >> $output_blob
if [ "$HERACLES_OUTPUT_LOGGING" = TRUE ]; then
 cat $output_blob
fi