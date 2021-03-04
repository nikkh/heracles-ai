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
if [ "$HERACLES_SINGLE_RG_NAME" ]; then 
 echo "Deployment will be to a single resource group: $HERACLES_SINGLE_RG_NAME" 
 resourceGroupName="$HERACLES_SINGLE_RG_NAME" 
else
 echo "Deployment will be to multiple resource groups" 
 resourceGroupName="${applicationName}-rg" 
fi
acrRegistryName="${HERACLES_ALIAS}acr"
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

echo "Creating app service hosting plan $hostingPlanName in group $resourceGroupName"
echo "<h1>Hosting Plan: $hostingPlanName</h1>" >> $output_blob
az appservice plan create -g $resourceGroupName --name $hostingPlanName --location $HERACLES_LOCATION --number-of-workers 1 --is-linux --sku S1 >> $output_blob

echo "Creating app insights component $webAppName in group $resourceGroupName"
echo "<h1>Application Insights: $webAppName</h1>" >> $output_blob
az monitor app-insights component create --app $webAppName --location $HERACLES_LOCATION --kind web -g $resourceGroupName --application-type web >> $output_blob
iraklionAIKey=$(az monitor app-insights component show --app $webAppName -g $resourceGroupName --query instrumentationKey -o tsv)


acrUser=$(az acr credential show -n $acrRegistryName --query username -o tsv)
acrPassword=$(az acr credential show -n $acrRegistryName --query passwords[0].value -o tsv)
echo "<p>ACR: $acrName</p>" >> $output_blob
echo "<p>ACR User Name: $acrUser</p>" >> $output_blob 
echo "<p>ACR Password: $acrPassword</p>" >> $output_blob 

echo "Creating app service for web site $webAppName in group $resourceGroupName"
echo "<h1>App Service (Web App): $webAppName</h1>" >> $output_blob

az webapp create \
  --name $webAppName \
  --plan $hostingPlanName \
  --resource-group $resourceGroupName \
  --docker-registry-server-user $acrUser \
  --docker-registry-server-password $acrPassword \
  --runtime "DOTNETCORE|3.1" \
   >> $output_blob

echo "<p>App Service (Web App): $webAppName</p>" >> $output_blob
iraklionAIKey=$(az monitor app-insights component show --app $webAppName -g $resourceGroupName --query instrumentationKey -o tsv)

echo "Updating App Settings for $webAppName"
echo "<p>Web App Settings:" >> $output_blob
az webapp config appsettings set -g $resourceGroupName -n $webAppName --settings AZURE__STORAGE__CONNECTIONSTRING=$storageConnectionString AZURE__SERVICEBUS__CONNECTIONSTRING=$serviceBusConnectionString ASPNETCORE_ENVIRONMENT=Development APPINSIGHTS_KEY=$iraklionAIKey >> $output_blob
echo "</p>" >> $output_blob
if [ "$HERACLES_OUTPUT_LOGGING" = TRUE ]; then
 cat $output_blob
fi
