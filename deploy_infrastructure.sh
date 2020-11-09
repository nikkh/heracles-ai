#!/bin/bash -e
output_blob=$OUTPUT_LOG_NAME
az extension add --name application-insights

echo '<!DOCTYPE html><html><head></head><body>' >> $output_blob
echo '<h1>Deployment Log</h1>' >> $output_blob
resourcesLink="https://portal.azure.com/#blade/HubsExtension/BrowseResourcesWithTag/tagName/HeraclesInstance/tagValue/$HERACLES_INSTANCE"
echo '<a href="'$resourcesLink'">Click here to access your azure resources</a>' >> $output_blob
echo '<p></p>' >> $output_blob

deployment-scripts/deploy_chania.sh
deployment-scripts/deploy_thessaloniki.sh
deployment-scripts/deploy_iraklion.sh
deployment-scripts/deploy_patra.sh
deployment-scripts/deploy_ioannina.sh
deployment-scripts/deploy_heracles.sh
echo '</body></html>' >> $output_blob

# Upload the deployment log to the zodiac storage account 
resourceGroupName="$HERACLES_ALIAS-rg"
storageAccountName=$(az storage account list -g $resourceGroupName --query [0].name -o tsv)
storageConnectionString=$(az storage account show-connection-string -n $storageAccountName -g $resourceGroupName --query connectionString -o tsv)
export AZURE_STORAGE_CONNECTION_STRING="$storageConnectionString"
az storage container create -n "results" --public-access off
az storage blob upload -c "results" -f $output_blob -n$output_blob
echo "Uploaded $output_blob to storage account $storageAccountName"

# Generate a SAS Token for direct access to the deployment log
today=$(date +%F)T
tomorrow=$(date --date="1 day" +%F)T
startTime=$(date --date="-2 hour" +%T)Z
expiryTime=$(date --date="2 hour" +%T)Z
start="$today$startTime"
expiry="$tomorrow$expiryTime"
url=$(az storage blob url -c "results" -n $output_blob -o tsv)
sas=$(az storage blob generate-sas -c "results" -n $output_blob --permissions r -o tsv --expiry $expiry --https-only --start $start)
echo "link to deployment-log is $url?$sas"