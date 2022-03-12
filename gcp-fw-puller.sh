#!/bin/bash

# Variables
appid='226221069972-asdasdasd.apps.googleusercontent.com'
secret='USjZqyssTfzxczxczxxcxzc'
scope="https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform.read-only"
header2="application/x-www-form-urlencoded"
time=$(($(date +%s)-25250)); jam=$(date -d @${time} '+%Y-%m')
project="proj-infrastructure"; file="${project}-firewalls-${jam}.csv"; temp="${project}-firewalls.csv"

#data retrieval
tkn=$(curl -sS -H "Content-Type: $header2" https://accounts.google.com/o/oauth2/token -d 'client_id='"${appid}"'&client_secret='"${secret}"'&refresh_token=1%2F%2F0gPT27ew6cuSJCgYIARAAGBASNwF-asdasdasdzxczxczxczxczx&grant_type=refresh_token' | jq '.access_token')
region+="asia-southeast2-a|asia-southeast2-b|"; IFS='|'; read -a reg <<<"${region%?}"
a=$(curl -sS https://compute.googleapis.com/compute/v1/projects/${project}/global/firewalls -H "Authorization: Bearer ${tkn//\"}")
length0=$(echo $a | jq '.items | length'); networks="https://www.googleapis.com/compute/v1/projects/proj-infrastructure/global/networks/"
name=$(echo $a | jq '.items[].name'); n+="$(echo ${name} | tr -d '\"' | tr '\n' '|')"
mode=$(echo $a | jq '.items[].direction'); m+="$(echo ${mode} | tr -d '\"' | tr '\n' '|')"
net=$(echo $a | jq '.items[].network'); nt+="$(echo ${net} | tr -d '\"' | tr '\n' '|')"
for (( j=0; j<${length0}; j++ )); do 
tart=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].targetTags'); tt+="$(echo ${tart} | tr -d '[\"]\n' | tr -d '[:blank:]')|"
tarr=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].targetRanges'); tr+="$(echo ${tarr} | tr -d '[\"]\n' | tr -d '[:blank:]')|"
srct=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].sourceTags'); st+="$(echo ${srct} | tr -d '[\"]\n' | tr -d '[:blank:]')|"
srcr=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].sourceRanges'); sr+="$(echo ${srcr} | tr -d '[\"]\n' | tr -d '[:blank:]')|"
alw=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].allowed'); al+="$(echo ${alw} | tr -d '{[\"]}\n' | tr -d '[:blank:]')|"
dny=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].denied'); dn+="$(echo ${dny} | tr -d '{[\"]}\n' | tr -d '[:blank:]')|"
done

#create csv
conf+="Number|Name|Direction|VPC|SourceRanges|SourceTags|TargetRanges|TargetTags|Allowed|Denied
"
IFS='|'; read -a name <<<"${n%?}"; IFS='|'; read -a mode <<<"${m%?}"
IFS='|'; read -a tart <<<"${tt%?}"; IFS='|'; read -a tarr <<<"${tr%?}"
IFS='|'; read -a srct <<<"${st%?}"; IFS='|'; read -a srcr <<<"${sr%?}"
IFS='|'; read -a alw <<<"${al%?}"; IFS='|'; read -a dny <<<"${dn%?}"
IFS='|'; read -a net <<<"${nt%?}"
j=1;for (( i=0; i<${length0}; i++ )); do 
conf+="${j}|${name[$i]}|${mode[$i]}|${net[$i]//${networks}}|${tart[$i]}|${tarr[$i]}|${srct[$i]}|${srcr[$i]}|${alw[$i]}|${dny[$i]}
";((j++))
done
printf "${conf}" | tr ',' '&' | tr '|' ',' >> ${file}
gcloud compute scp /home/admin/Test/${file} labghifari@lab-ghifari:/var/www/html/temp/${temp} --zone=asia-southeast2-a --project=project-lab
