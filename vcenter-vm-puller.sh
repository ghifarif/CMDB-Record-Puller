#!/bin/bash

# Variables
time=$(($(date +%s)-25250)); jam=$(date -d @${time} '+%Y-%m')
winfile="windows-vms-${jam}.csv"; wintemp="windows-vms.csv"
linfile="linux-vms-${jam}.csv"; lintemp="linux-vms.csv"

#target itemids/names
hids+="10465|10534|10574|10575|10518|10468|10523|10535|10526|10474|10492|10508|10491|10473|"
wids+="37315|37326|37343|37317|37335|42053|42054|-|-|-|"
wnames+="vm1|vm2|vm3|vm4|vm5|vm6|vm7|vm8|vm9|"

hids+="10483|10485|10565|10538|10540|10541|10545|10544|10488|10506|10484|10527|10533|10543|10581|10476|"
lids+="38161|38172|38189|38163|38181|43434|43436|43437|-|-|"
lnames+="vm1|vm2|vm3|vm4|vm5|vm6|vm7|vm8|vm9|"

#data retrieval
IFS='|'; read -a wname <<<"${wnames%?}"
IFS='|'; read -a wid <<<"${wids%?}"
length=${#wid[@]}
j=0; for (( i=0; i<${length}; i++ )); do if [[ ${wid[$i]} != "-" ]]; then if [[ ${j} < 2 ]]; then 
wv=$(curl -sS -H "Content-Type: application/json" http://$ZBXIP/zabbix/api_jsonrpc.php -d '{"jsonrpc": "2.0","method": "history.get","params": {"output": "extend","history": 1,"itemids": "'"${wid[$i]}"'","sortfield":"clock","sortorder":"DESC","limit":"10"},"auth": "de57b5930200ad5493af7738757a25c5","id": 1}' | jq '.result[0].value')
else wv=$(curl -sS -H "Content-Type: application/json" http://$ZBXIP/zabbix/api_jsonrpc.php -d '{"jsonrpc": "2.0","method": "history.get","params": {"output": "extend","history": 3,"itemids": "'"${wid[$i]}"'","sortfield":"clock","sortorder":"DESC","limit":"10"},"auth": "de57b5930200ad5493af7738757a25c5","id": 1}' | jq '.result[0].value | tonumber'); fi
if [[ ${j} > 3 ]]; then winval+="$(printf $((${wv}/1072048576)))|"; else winval+="${wv}|"; fi
else winval+="-|"; fi; if [[ ${j} == 10 ]]; then j=0; fi; ((j++))
done
IFS='|'; read -a lname <<<"${lnames%?}"
IFS='|'; read -a lid <<<"${lids%?}"
length=${#lid[@]}
j=0; for (( i=0; i<${length}; i++ )); do if [[ ${lid[$i]} != "-" ]]; then if [[ ${j} < 2 ]]; then 
lv=$(curl -sS -H "Content-Type: application/json" http://$ZBXIP/zabbix/api_jsonrpc.php -d '{"jsonrpc": "2.0","method": "history.get","params": {"output": "extend","history": 1,"itemids": "'"${lid[$i]}"'","sortfield":"clock","sortorder":"DESC","limit":"10"},"auth": "de57b5930200ad5493af7738757a25c5","id": 1}' | jq '.result[0].value')
else lv=$(curl -sS -H "Content-Type: application/json" http://$ZBXIP/zabbix/api_jsonrpc.php -d '{"jsonrpc": "2.0","method": "history.get","params": {"output": "extend","history": 3,"itemids": "'"${lid[$i]}"'","sortfield":"clock","sortorder":"DESC","limit":"10"},"auth": "de57b5930200ad5493af7738757a25c5","id": 1}' | jq '.result[0].value | tonumber'); fi
if [[ ${j} > 3 ]]; then linval+="$(printf $((${lv}/1072048576)))|"; else linval+="${lv}|"; fi
else linval+="-|"; fi; if [[ ${j} == 10 ]]; then j=0; fi; ((j++))
done
IFS='|'; read -a hip <<<"${hids%?}"
length=${#hip[@]}
for (( k=0; k<${length}; k++ )); do
hips+="$(curl -sS -H "Content-Type: application/json" http://$ZBXIP/zabbix/api_jsonrpc.php -d '{"jsonrpc": "2.0","method": "hostinterface.get","params": {"output": "extend","hostids": "'"${hip[$k]}"'"},"auth": "de57b5930200ad5493af7738757a25c5","id": 1}' | jq '.result[0].ip')|"
done

#create csv
conf+="Number,Name,Cluster,IP,Host,State,CPU,Memory(GB),Disk-C(GB),"
conf+="Disk-D(GB),Disk-E(GB),Disk-F(GB),Disk-G(GB)
"
conf2+="Number,Name,Cluster,IP,Host,State,CPU,Memory(GB),Vol-root(GB),"
conf2+="Vol-backup(GB),Vol-oracle(GB),Vol-oradata(GB),Vol-oraindex(GB)
"
IFS='|'; read -a wv <<<"${winval%?}"; length0=${#wv[@]}
IFS='|'; read -a lv <<<"${linval%?}"; length1=${#lv[@]}
IFS='|'; read -a ip <<<"${hips%?}"
k=0; j=0;for (( i=0; i<${length0}; i++ )); do if [[ $((i%10)) == 0 ]]; then
conf+="$((${j}+1)),${wname[$j]},${wv[$i]},${ip[$k]},${wv[$i+1]},${wv[$i+2]},${wv[$i+3]},"
conf+="${wv[$i+4]},${wv[$i+5]},${wv[$i+6]},${wv[$i+7]},${wv[$i+8]},${wv[$i+9]}
";((j++));((k++))
fi; done
j=0;for (( i=0; i<${length1}; i++ )); do if [[ $((i%10)) == 0 ]]; then
conf2+="$((${j}+1)),${lname[$j]},${lv[$i]},${ip[$k]},${lv[$i+1]},${lv[$i+2]},${lv[$i+3]},"
conf2+="${lv[$i+4]},${lv[$i+5]},${lv[$i+6]},${lv[$i+7]},${lv[$i+8]},${lv[$i+9]}
";((j++));((k++))
fi; done
printf "${conf}" >> ${winfile}; printf "${conf2}" >> ${linfile}
gcloud compute scp /home/admin/Test/${winfile} labghifari@lab-ghifari:/var/www/html/temp/${wintemp} --zone=asia-southeast2-a --project=project-lab
gcloud compute scp /home/admin/Test/${linfile} labghifari@lab-ghifari:/var/www/html/temp/${lintemp} --zone=asia-southeast2-a --project=project-lab
