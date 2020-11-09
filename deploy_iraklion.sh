#!/bin/bash -e
output_blob=$OUTPUT_LOG_NAME
echo "<h2>Iraklion Infrastructure</h2>" >> $output_blob
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo         Deploying iraklion
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ---Global Variables
echo "IRAKLION_ALIAS: $IRAKLION_ALIAS"
echo "HERACLES_LOCATION: $HERACLES_LOCATION"
echo

# set local variables
appservice_webapp_sku="S1 Standard"
acrSku="Standard"
imageName='iraklionapi:$(Build.BuildId)'
echo ---Local Variables
echo "App service Sku: $appservice_webapp_sku"
echo "Azure Container Registry Sku: $acrSku"
echo "Image name: $imageName"
echo 

# Derive as many variables as possible
applicationName="${IRAKLION_ALIAS}"
webAppName="${applicationName}-api"
hostingPlanName="${applicationName}-plan"
resourceGroupName="${applicationName}-rg"
acrRegistryName="${IRAKLION_ALIAS}acr"
serviceBusNamespace="${applicationName}sb"
storageAccountName=${applicationName}$RANDOM

echo ---Derived Variables
echo "Application Name: $applicationName"
echo "Resource Group Name: $resourceGroupName"
echo "Web App Name: $webAppName"
echo "Hosting Plan: $hostingPlanName"
echo "ACR Name: $acrRegistryName"
echo "Service Bus Namespace: $serviceBusNamespace"
echo "Storage account name: $storageAccountName"
echo

echo "Creating resource group $resourceGroupName in $HERACLES_LOCATION"
az group create -l "$HERACLES_LOCATION" --n "$resourceGroupName" --tags HeraclesInstance=$HERACLES_INSTANCE Application=heracles MicrososerviceName=iraklion MicroserviceID=$applicationName PendingDelete=true -o none
echo "<p>Resource Group: $resourceGroupName</p>" >> $output_blob
echo "Creating service bus namespace $serviceBusNamespace in group $resourceGroupName"
az servicebus namespace create -g $resourceGroupName -n $serviceBusNamespace >> $output_blob
az servicebus queue create -g $resourceGroupName --namespace-name $serviceBusNamespace --name ioannina-queue >> $output_blob
az servicebus queue create -g $resourceGroupName --namespace-name $serviceBusNamespace --name patra-queue >> $output_blob
echo "<p>Service Bus Namespace: $serviceBusNamespace</p>" >> $output_blob
serviceBusConnectionString=$(az servicebus namespace authorization-rule keys list -g $resourceGroupName --namespace-name $serviceBusNamespace -n RootManageSharedAccessKey --query 'primaryConnectionString' -o tsv)
echo "<p>Service Bus Connection String: $serviceBusConnectionString</p>" >> $output_blob
echo "Creating storage account $storageAccountName in $resourceGroupName"
 az storage account create \
  --name $storageAccountName \
  --location $HERACLES_LOCATION \
  --resource-group $resourceGroupName \
  --sku Standard_LRS >> $output_blob
echo "<p>Storage Account Name: $storageAccountName</p>" >> $output_blob 
storageConnectionString=$(az storage account show-connection-string -n $storageAccountName -g $resourceGroupName --query connectionString -o tsv)
echo "<p>Storage Connection String: $storageConnectionString</p>" >> $output_blob 

echo "Creating app service $webAppName in group $resourceGroupName"
 az group deployment create -g $resourceGroupName \
    --template-file iraklion/iraklion-acr.json  \
    --parameters webAppName=$webAppName hostingPlanName=$hostingPlanName appInsightsLocation=$HERACLES_LOCATION \
        sku="${appservice_webapp_sku}" registryName=$acrRegistryName imageName="$imageName" registryLocation="$HERACLES_LOCATION" registrySku="$acrSku" -o none
echo "<p>App Service (Web App): $webAppName</p>" >> $output_blob
iraklionAIKey=$(az monitor app-insights component show --app $webAppName -g $resourceGroupName --query instrumentationKey -o tsv)

echo "Updating App Settings for $webAppName"
echo "<p>Web App Settings:" >> $output_blob
az webapp config appsettings set -g $resourceGroupName -n $webAppName --settings AZURE__STORAGE__CONNECTIONSTRING=$storageConnectionString AZURE__SERVICEBUS__CONNECTIONSTRING=$serviceBusConnectionString ASPNETCORE_ENVIRONMENT=Development APPINSIGHTS_KEY=$iraklionAIKey >> $output_Blob
echo "</p>" >> $output_blob
  
