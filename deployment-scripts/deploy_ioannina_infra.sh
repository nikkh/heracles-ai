#!/bin/bash -e
output_blob=$OUTPUT_LOG_NAME
echo "<h2>Ioannina Infrastructure</h2>" >> $output_blob
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo         Deploying Ioannina 
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ---Global Variables
echo "IOANNINA_ALIAS: $IOANNINA_ALIAS"
echo "HERACLES_LOCATION: $HERACLES_LOCATION"
echo "OUTPUT: $OUTPUT"
echo
# set local variables
# Derive as many variables as possible
applicationName="${IOANNINA_ALIAS}"
resourceGroupName="${applicationName}-rg"
storageAccountName=${applicationName}$RANDOM
functionAppName="${applicationName}-func"

echo "IRAKLION_ALIAS: $IRAKLION_ALIAS"
iraklionApplicationName="${IRAKLION_ALIAS}"
iraklionResourceGroupName="${iraklionApplicationName}-rg"
iraklionServiceBusNamespace="${iraklionApplicationName}sb"
iraklionServiceBusConnectionString=$(az servicebus namespace authorization-rule keys list -g $iraklionResourceGroupName --namespace-name $iraklionServiceBusNamespace -n RootManageSharedAccessKey --query 'primaryConnectionString' -o tsv)

# iraklion application insights info
iraklionWebAppName=$iraklionApplicationName-api
iraklionAIKey=$(az monitor app-insights component show --app $iraklionWebAppName -g $iraklionResourceGroupName --query instrumentationKey -o tsv)


echo ---Derived Variables
echo "Application Name: $applicationName"
echo "Resource Group Name: $resourceGroupName"
echo "Storage Account Name: $storageAccountName"
echo "Function App Name: $functionAppName"
echo

echo "Creating resource group $resourceGroupName in $HERACLES_LOCATION"
az group create -l "$HERACLES_LOCATION" --n "$resourceGroupName" --tags  HeraclesInstance=$HERACLES_INSTANCE Application=heracles MicrososerviceName=ioannina MicroserviceID=$applicationName PendingDelete=true >> $output_blob
echo "<p>Resource Group: $resourceGroupName</p>" >> $output_blob

echo "Creating storage account $storageAccountName in $resourceGroupName"
az storage account create \
--name $storageAccountName \
--location $HERACLES_LOCATION \
--resource-group $resourceGroupName \
--sku Standard_LRS >> $output_blob
echo "<p>Storage Account: $storageAccountName</p>" >> $output_blob

echo "Creating function app $functionAppName in $resourceGroupName"
echo "<p>Function App: $functionAppName</p>" >> $output_blob
echo "<p>Function App Settings:" >> $output_blob
az functionapp create \
 --name $functionAppName \
 --storage-account $storageAccountName \
 --consumption-plan-location $HERACLES_LOCATION \
 --resource-group $resourceGroupName \
 --functions-version 3 \
 --app-insights $iraklionWebAppName \
 --app-insights-key $iraklionAIKey >> $output_blob
echo "</p>" >> $output_blob
 
echo "Updating App Settings for $functionAppName"
settings="ServiceBusConnection=$iraklionServiceBusConnectionString"
echo "<p>Function App Settings:" >> $output_blob
az webapp config appsettings set -g $resourceGroupName -n $functionAppName --settings "$settings"  >> $output_blob
echo "</p>" >> $output_blob
if [ "$HERACLES_OUTPUT_LOGGING" = TRUE ]; then
 cat $output_blob
fi