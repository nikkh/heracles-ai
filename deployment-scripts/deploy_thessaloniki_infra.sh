#!/bin/bash -e
output_blob=$OUTPUT_LOG_NAME
echo "<h2>Thessaloniki Infrastructure</h2>" >> $output_blob
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo         Deploying thessaloniki 
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ---Global Variables
echo "THESSALONIKI_ALIAS: $THESSALONIKI_ALIAS"
echo "HERACLES_LOCATION: $HERACLES_LOCATION"
echo "DB_ADMIN_USER: $DB_ADMIN_USER"
echo "DB_ADMIN_PASSWORD: $DB_ADMIN_PASSWORD"
echo

# set local variables
appservice_webapp_sku="S1 Standard"

echo ---Local Variables
echo "App service Sku: $appservice_webapp_sku"
echo 

# Derive as many variables as possible
applicationName="${THESSALONIKI_ALIAS}"
webAppName="${applicationName}-api"
hostingPlanName="${applicationName}-plan"
resourceGroupName="${applicationName}-rg"
databaseConnectionString="Server=tcp:$dbServerName.database.windows.net;Database=$dbName;User ID=$DB_ADMIN_USER;Password=$DB_ADMIN_PASSWORD;Encrypt=True;Connection Timeout=30;"
dbServerName="${CHANIA_ALIAS}-db-server"
dbName="${CHANIA_ALIAS}-web-db"
storageAccountName=${applicationName}$RANDOM

echo ---Derived Variables
echo "Application Name: $applicationName"
echo "Resource Group Name: $resourceGroupName"
echo "Web App Name: $webAppName"
echo "Hosting Plan: $hostingPlanName"
echo "DB Server Name: $dbServerName"
echo "DB Name: $dbName"
echo "Database connection string: $databaseConnectionString"
echo "Storage account name: $storageAccountName"
echo

echo "Creating resource group $resourceGroupName in $HERACLES_LOCATION"
echo "<p>Resource Group: $resourceGroupName</p>" >> $output_blob
az group create -l "$HERACLES_LOCATION" --n "$resourceGroupName" --tags  HeraclesInstance=$HERACLES_INSTANCE Application=heracles MicrososerviceName=thessaaloniki MicroserviceID=$applicationName PendingDelete=true >> $output_blob
echo "<p>Resource Group: $resourceGroupName</p>" >> $output_blob >> $output_blob

echo "Creating storage account $storageAccountName in group $resourceGroupName"
echo "<p>Storage Account: $storageAccountName</p>" >> $output_blob
 az storage account create \
  --name $storageAccountName \
  --location $HERACLES_LOCATION \
  --resource-group $resourceGroupName \
  --sku Standard_LRS  \
  --tags  HeraclesInstance=$HERACLES_INSTANCE Application=heracles MicrososerviceName=thessaaloniki MicroserviceID=$applicationName PendingDelete=true >> $output_blob
  

storageConnectionString=$(az storage account show-connection-string -n $storageAccountName -g $resourceGroupName --query connectionString -o tsv)
echo "<p>Storage Account Connection String: $storageConnectionString</p>" >> $output_blob

echo "Creating app service $webAppName in group $resourceGroupName "
 az group deployment create -g $resourceGroupName \
    --template-file thessaloniki/thessaloniki.json  \
    --parameters webAppName=$webAppName hostingPlanName=$hostingPlanName appInsightsLocation=$HERACLES_LOCATION \
        sku="${appservice_webapp_sku}" databaseConnectionString="{$databaseConnectionString}" >> $output_blob
echo "<p>App Service (Web App): $webAppName</p>" >> $output_blob


# Build SQL connecion string
xbaseDbConnectionString=$(az sql db show-connection-string -c ado.net -s $dbServerName -n $dbName -o tsv)
xdbConnectionStringWithUser="${xbaseDbConnectionString/<username>/$DB_ADMIN_USER}"
xsqlConnectionString="${xdbConnectionStringWithUser/<password>/$DB_ADMIN_PASSWORD}"
echo "<p>SQL Connection string for db=$dbName: $xsqlConnectionString</p>" >> $output_blob

# thessaloniki application insights info
thessalonikiAIKey=$(az monitor app-insights component show --app $webAppName -g $resourceGroupName --query instrumentationKey -o tsv)
# Attempt to get App Insights configured without the needd for the portal
APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$thessalonikiAIKey;"
APPINSIGHTS_INSTRUMENTATIONKEY=$thessalonikiAIKey
ApplicationInsightsAgent_EXTENSION_VERSION='~2'

echo "Updating App Settings for $webAppName"
echo "<p>Web App Settings:" >> $output_blob
az webapp config appsettings set -g $resourceGroupName -n $webAppName \
 --settings AZURE__STORAGE__CONNECTIONSTRING=$storageConnectionString "AZURE__A3SSDEVDB__CONNECTIONSTRING=$xsqlConnectionString" ASPNETCORE_ENVIRONMENT=Development APPLICATIONINSIGHTS_CONNECTION_STRING=$APPLICATIONINSIGHTS_CONNECTION_STRING APPINSIGHTS_INSTRUMENTATIONKEY=$APPINSIGHTS_INSTRUMENTATIONKEY ApplicationInsightsAgent_EXTENSION_VERSION=$ApplicationInsightsAgent_EXTENSION_VERSION >> deployment-log.txt >> $output_blob
echo "</p>" >> $output_blob
if [ "$HERACLES_OUTPUT_LOGGING" = TRUE ]; then
 cat $output_blob
fi
