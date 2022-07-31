#!/bin/bash
SMART_PARAMS="1 5 10 187 123 177 178 179 240" #Write S.M.A.R.T. attrubutes space separated
TLGRM_TOKEN="0123456789:AABCD_186Bku5E8TCFaqBUx48jwkt5JbkA4" #Your telegram API Token
TLGRM_CHAT_ID="987654321" #Your chat ID
CHECK_INTERVAL="5" #in seconds. Optional. By default interval = 1h
HOSTNAME=$(hostname) 
device=$(lsblk -a | grep disk | awk '{ print $1 }')

while IFS= read -r line
do
   volume+="-v /dev/$line:/dev/$line "
   env+="$line "
done < <(printf '%s\n' "$device")

docker run -d --rm \
	--name smartalert \
	-e HOSTNAME="$HOSTNAME" \
	-e BLOCK_DEVICE="$env" \
	-e SMART_PARAMS="$SMART_PARAMS" \
	-e TLGRM_TOKEN="$TLGRM_TOKEN" \
	-e TLGRM_CHAT_ID="$TLGRM_CHAT_ID" \
	-e CHECK_INTERVAL="$CHECK_INTERVAL" \
	--privileged \
	$volume \
	balanial/smartalert:latest
