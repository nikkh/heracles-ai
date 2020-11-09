#!/bin/sh -e
clear
HERACLES_USER=nikkh
HERACLES_PAT='<<enter PAT here>>'
GITHUB_REPOSITORY='nikkh/heracles-ai'
alias=$(jq .alias setup-parameters.json -r)
echo "alias=$alias"

res=$(curl --location --request GET "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/secrets/public-key" \
--header "Authorization: Bearer $HERACLES_PAT" \
--header 'Cookie: logged_in=no; _octo=GH1.1.1387838137.1581271944')

echo "res=$res"
repo_public_key=$(echo $res | jq .key -r)
echo "repo_public_key=$repo_public_key"
repo_public_key_id=$(echo $res | jq .key_id -r)
echo "repos_public_key_id=$repo_public_key_id"
encrypted_value=$(node encrypt_secret.js $alias $repo_public_key)
echo "encrypted_value=$encrypted_value"
curl_body=$(jq -n --arg key_id "$repo_public_key_id" --arg encrypted_value "$encrypted_value" '{encrypted_value: $encrypted_value, key_id: $key_id}')
echo "curl_body=$curl_body"


curl --location --request PUT "https://api.github.com/repos/$GITHUB_REPOSITORY/actions/secrets/ACR_PASSWORD" \
--header "Authorization: Bearer $HERACLES_PAT" \
--header 'Content-Type: application/json' \
--header 'Cookie: logged_in=no; _octo=GH1.1.1387838137.1581271944' \
--data-raw "$curl_body"