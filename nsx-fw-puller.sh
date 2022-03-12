#!/bin/bash

# Variables
time=$(($(date +%s)-25250)); jam=$(date -d @${time} '+%Y-%m')
nsxfile="NSX-firewalls-${jam}.csv"; nsxtemp="NSX-firewalls.csv"
aplfile="app-groups-${jam}.csv"; apltemp="app-groups.csv"
iplfile="ip-groups-${jam}.csv"; ipltemp="ip-groups.csv"

#data retrieval
rule=$(curl -sSk -H "Accept: $header2" https://$NSXIP/api/4.0/edges/edge-3/firewall/config -H "Authorization: Basic YWRtaW5pc3RyYXRasdasdasdzxczxczxc==")
rul=$(echo $rule | xmlstarlet sel -t -m '/firewall/firewallRules/firewallRule' -v id -o "," -v name -o "," -v enabled -o "," -v action -o "," -v source/groupingObjectId -o "," -v source/ipAddress -o "," -v destination/groupingObjectId -o "," -v destination/ipAddress -o "," -v application/applicationId -o "," -v application/service/protocol -o "," -v application/service/port -o "," -v application/service/sourcePort -o ":" | tr '\n' ' ' | tr ':' '\n')
app=$(curl -sSk -H "Accept: $header2" https://$NSXIP/api/2.0/services/application/scope/globalroot-0 -H "Authorization: Basic YWRtaW5pc3RyYXRasdasdasdzxczxczxc==")
apl=$(echo $app | xmlstarlet sel -t -m '/list/application' -v objectId -o ","  -v type/typeName -o "," -v name -o "," -v element/applicationProtocol -o "," -v element/value -nl)
ip=$(curl -sSk -H "Accept: $header2" https://$NSXIP/api/2.0/services/ipset/scope/globalroot-0 -H "Authorization: Basic YWRtaW5pc3RyYXRasdasdasdaszxczxczxczx==")
ipl=$(echo $ip | xmlstarlet sel -t -m '/list/ipset' -v objectId -o ","  -v type/typeName -o "," -v name -o "," -v value -nl)

#create csv
conf1+="ID,Name,Enabled,Action,SourceObjectID,SourceIPList,DestinationObjectID,DestinationIPList,AppID,Protocol,DestPort,SrcPort
${rul}"
conf2+="ID,Type,Name,Protocol,Port
${apl}"
conf3+="ID,Type,Name,IP
${ipl}"
printf "${conf1}" | sed -e 's/\&amp;/\&/g' > ${nsxfile}; printf "${conf2}" > ${aplfile}; printf "${conf3}" > ${iplfile}
gcloud compute scp /home/admin/${nsxfile} labghifari@lab-ghifari:/var/www/html/temp/${nsxtemp} --zone=asia-southeast2-a --project=project-lab
gcloud compute scp /home/admin/${aplfile} labghifari@lab-ghifari:/var/www/html/temp/${apltemp} --zone=asia-southeast2-a --project=project-lab
gcloud compute scp /home/admin/${iplfile} labghifari@lab-ghifari:/var/www/html/temp/${ipltemp} --zone=asia-southeast2-a --project=project-lab
