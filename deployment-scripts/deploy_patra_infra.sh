#!/bin/bash -e
output_blob=$OUTPUT_LOG_NAME
echo "<h2>Patra Infrastructure</h2>" >> $output_blob
echo "Starting Patra Deploy..." >> $output_blob
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo         Deploying Patra 
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ---Global Variables
echo "PATRA_ALIAS: $PATRA_ALIAS"
echo "HERACLES_LOCATION: $HERACLES_LOCATION"
echo
# set local variables
# Derive as many variables as possible
applicationName="${PATRA_ALIAS}"
if [ "$HERACLES_SINGLE_RG_NAME" ]; then 
 echo "Deployment will be to a single resource group: $HERACLES_SINGLE_RG_NAME" 
 resourceGroupName="$HERACLES_SINGLE_RG_NAME" 
else
 echo "Deployment will be to multiple resource groups" 
 resourceGroupName="${applicationName}-rg" 
fi
storageAccountName=${applicationName}$RANDOM
functionAppName="${applicationName}-func"

echo "IRAKLION_ALIAS: $IRAKLION_ALIAS"
iraklionApplicationName="${IRAKLION_ALIAS}"
iraklionResourceGroupName="${iraklionApplicationName}-rg"
iraklionServiceBusNamespace="${iraklionApplicationName}sb"
iraklionServiceBusConnectionString=$(az servicebus namespace authorization-rule keys list -g $iraklionResourceGroupName --namespace-name $iraklionServiceBusNamespace -n RootManageSharedAccessKey --query 'primaryConnectionString' -o tsv)

echo ---Derived Variables
echo "Application Name: $applicationName"
echo "Resource Group Name: $resourceGroupName"
echo "Storage Account Name: $storageAccountName"
echo "Function App Name: $functionAppName"
echo

echo "Creating resource group $resourceGroupName in $HERACLES_LOCATION"
az group create -l "$HERACLES_LOCATION" --n "$resourceGroupName" --tags  HeraclesInstance=$HERACLES_INSTANCE Application=heracles MicrososerviceName=patra MicroserviceID=$applicationName PendingDelete=true >> $output_blob
echo "<p>Resource Group: $resourceGroupName</p>" >> $output_blob

echo "Creating storage account $storageAccountName in $resourceGroupName"
az storage account create \
--name $storageAccountName \
--location $HERACLES_LOCATION \
--resource-group $resourceGroupName \
--sku Standard_LRS -o none
echo "<p>Storage Account: $storageAccountName</p>" >> $output_blob

echo "Creating function app $functionAppName in $resourceGroupName"
az functionapp create \
 --name $functionAppName \
 --storage-account $storageAccountName \
 --consumption-plan-location $HERACLES_LOCATION \
 --resource-group $resourceGroupName \
 --functions-version 3 >> $output_blob
echo "<p>Function App: $functionAppName</p>" >> $output_blob

# az functionapp config appsettings delete --name $functionAppName --resource-group $resourceGroupName --setting-names APPINSIGHTS_INSTRUMENTATIONKEY APPLICATIONINSIGHTS_CONNECTION_STRING  >> $output_blob
# az monitor app-insights component delete --app $functionAppName -g $resourceGroupName >> $output_blob

echo "Updating App Settings for $functionAppName"
settings="ServiceBusConnection=$iraklionServiceBusConnectionString WEBSITE_WEBDEPLOY_USE_SCM=true" 

echo "<p>Function App Settings:" >> $output_blob

az webapp config appsettings set -g $resourceGroupName -n $functionAppName --settings "$settings"  >> $output_blob
echo "</p>" >> $output_blob
if [ "$HERACLES_OUTPUT_LOGGING" = TRUE ]; then
 cat $output_blob
fi
