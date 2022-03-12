#!/bin/bash

# Variables
appid='226221069972-asdasdasd.apps.googleusercontent.com'
secret='USjZqyssTfzxczxczxxcxzc'
scope="https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform.read-only"
header2="application/x-www-form-urlencoded"
time=$(($(date +%s)-25250)); jam=$(date -d @${time} '+%Y-%m')
project="proj-infrastructure"; file="${project}-instances-${jam}.csv"; temp="${project}-instances.csv"

#data retrieval
tkn=$(curl -sS -H "Content-Type: $header2" https://accounts.google.com/o/oauth2/token -d 'client_id='"${appid}"'&client_secret='"${secret}"'&refresh_token=1%2F%2F0gPT27ew6cuSJCgYIARAAGBASNwF-asdasdasdzxczxczxczxczx&grant_type=refresh_token' | jq '.access_token')
region+="asia-southeast2-a|asia-southeast2-b|asia-southeast2-c|"; IFS='|'; read -a reg <<<"${region%?}"
for (( k=0; k<${#reg[@]}; k++ )); do 
a=$(curl -sS https://compute.googleapis.com/compute/v1/projects/${project}/zones/${reg[$k]}/instances -H "Authorization: Bearer ${tkn//\"}")
urlt="https://www.googleapis.com/compute/v1/projects/${project}/zones/${reg[$k]}/machineTypes/"; urlz="https://www.googleapis.com/compute/v1/projects/${project}/zones/"
length0=$(echo $a | jq '.items | length'); length1=$(($length1 + $length0))
name=$(echo $a | jq '.items[].name'); n+="$(echo ${name} | tr -d '\"' | tr '\n' '|')"
type=$(echo $a | jq '.items[].machineType'); typ=$(echo ${type//${urlt}}); t+="$(echo ${typ} | tr -d '\"' | tr '\n' '|')"
stat=$(echo $a | jq '.items[].status'); s+="$(echo ${stat} | tr -d '\"' | tr '\n' '|')"
zone=$(echo $a | jq '.items[].zone'); zon=$(echo ${zone//${urlz}}); z+="$(echo ${zon} | tr -d '\"' | tr '\n' '|')"
for (( j=0; j<${length0}; j++ )); do 
ip=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].networkInterfaces[].networkIP')
itemp="$(echo ${ip} | tr -d '\"' | tr '\n' ',')"; i+="${itemp%?}|"
disk=$(echo $a | jq --arg j "$j" '.items[$j|tonumber].disks[].diskSizeGb')
dtemp="$(echo ${disk} | tr -d '\"' | tr '\n' ',')"; d+="${dtemp%?}|"
done; done

#create csv
conf+="Number|Name|Type|Status|Zone|IP|Disk(GB)
"
IFS='|'; read -a name <<<"${n%?}"; IFS='|'; read -a type <<<"${t%?}"
IFS='|'; read -a stat <<<"${s%?}"; IFS='|'; read -a zone <<<"${z%?}"
IFS='|'; read -a ip <<<"${i%?}"; IFS='|'; read -a disk <<<"${d%?}"
j=1;for (( i=0; i<${length1}; i++ )); do 
conf+="${j}|${name[$i]}|${type[$i]}|${stat[$i]}|${zone[$i]}|${ip[$i]}|${disk[$i]}
";((j++))
done
printf "${conf}" | tr ',' '&' | tr '|' ',' >> ${file}
gcloud compute scp /home/admin/Test/${file} labghifari@lab-ghifari:/var/www/html/temp/${temp} --zone=asia-southeast2-a --project=project-lab
