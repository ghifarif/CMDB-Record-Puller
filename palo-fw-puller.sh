#!/bin/bash

# Variables
time=$(($(date +%s)-25250)); jam=$(date -d @${time} '+%Y-%m')
file="PA-firewalls-${jam}.csv"; temp="PA-firewalls.csv"

#data retrieval
a=$(curl -sS 'http://$PALOIP/restapi/9.0/Policies/SecurityRules?location=vsys&vsys=vsys1&key=LUFasdasdasdzxcxzxczxczxc==')
length0=$(echo $a | jq '.result.entry | length'); length1=$(($length0 + $length0))
name=$(echo $a | jq '.result.entry[]."@name"'); n+="$(echo ${name} | tr '\"' '|')"
dstz=$(echo $a | jq '.result.entry[].to.member'); dz+="$(echo ${dstz} | tr -d '[]' | tr '\"' '|')"
srcz=$(echo $a | jq '.result.entry[].from.member'); sz+="$(echo ${srcz} | tr -d '[]' | tr '\"' '|')"
dstn=$(echo $a | jq '.result.entry[].destination.member'); dn+="$(echo ${dstn} | tr -d '\"' | tr '[]' '|')"
srcn=$(echo $a | jq '.result.entry[].source.member'); sn+="$(echo ${srcn} | tr -d '\"' | tr '[]' '|')"
app=$(echo $a | jq '.result.entry[].application.member'); ap+="$(echo ${app} | tr -d '\"' | tr '[]' '|')"
svc=$(echo $a | jq '.result.entry[].service.member'); s+="$(echo ${svc} | tr -d '\"' | tr '[]' '|')"
user=$(echo $a | jq '.result.entry[]."source-user".member'); u+="$(echo ${user} | tr -d '\"' | tr '[]' '|')"
act=$(echo $a | jq '.result.entry[].action'); a+="$(echo ${act} | tr '\"' '|')"

#create csv
conf+="Number|Name|DstZone|SrcZone|DstTarget|SrcTarget|Application|Service|User|Action
"
IFS='|'; read -a name <<<"${n%?}"; IFS='|'; read -a dstz <<<"${dz%?}"
IFS='|'; read -a srcz <<<"${sz%?}"; IFS='|'; read -a dstn <<<"${dn%?}"
IFS='|'; read -a srcn <<<"${sn%?}"; IFS='|'; read -a app <<<"${ap%?}"
IFS='|'; read -a svc <<<"${s%?}"; IFS='|'; read -a user <<<"${u%?}"
IFS='|'; read -a act <<<"${a%?}"
j=1;for (( i=0; i<${length1}; i++ )); do if [[ $((i%2)) -ne 0 ]]; then
conf+="${j}|${name[$i]}|${dstz[$i]}|${srcz[$i]}|${dstn[$i]}|${srcn[$i]}|${app[$i]}|${svc[$i]}|${user[$i]}|${act[$i]}
";((j++))
fi; done
printf "${conf}" | tr ',' '&' | tr '|' ',' >> ${file}
gcloud compute scp /home/admin/Test/${file} labghifari@lab-ghifari:/var/www/html/temp/${temp} --zone=asia-southeast2-a --project=project-lab
