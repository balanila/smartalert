#!/bin/bash
#set -x
SMART_PARAMS="${SMART_PARAMS:=5}"

CHECK_INTERVAL="${CHECK_INTERVAL:=3600}"
if [ -z $TLGRM_TOKEN ]; then
	echo "missing TLGRM_TOKEN value"
	exit 1
fi

if [ -z $TLGRM_CHAT_ID ]; then
	echo "missing TLGRM_CHAT_ID value"
        exit 1
fi

TLGRM_URL="https://api.telegram.org/bot${TLGRM_TOKEN}/sendMessage?chat_id=${TLGRM_CHAT_ID}&text="
curl "${TLGRM_URL}Telegram%20Alerting%20has%20been%20started"

#Create ass. array
declare -A deviceArray=()
getDate() {

date +'%d/%m/%Y %H:%M:%S'
}


#Function sendAlert
sendAlert() {
msgOldValue="$1"
msgNewValue="$2"
msgDeviceName="$3"
msgAttr="$4"
date=$(getDate)
TLGRM_MSG="$date S.M.A.R.T. alert on host $HOSTNAME: Attribute $msgAttr for /dev/$msgDeviceName has been changed! Old value: $msgOldValue, new value: $msgNewValue"
TLGRM_MSG="$(sed 's/[[:space:]]/%20/g'<<<$TLGRM_MSG)"

curl "${TLGRM_URL}${TLGRM_MSG}"

}


#Function iterateArray

iterateArray() {
	varDevices="$2"
	varSmart="\$$3"
	deviceCount=$(awk '{ FS = " " } ; { print NF}'<<<$BLOCK_DEVICE)
	smartCount=$(awk '{ FS = " " } ; { print NF}'<<<$SMART_PARAMS)
	echo ">>>>Device Count: $deviceCount, smart params count: $smartCount"
        for (( c=1; c<=$deviceCount; c++ ))
        do
		for (( s=1; s<=$smartCount; s++ ))
		do
			sleep 1
		device=$(awk -v c="$c" '{ print $c }'<<<$BLOCK_DEVICE)
		param=$(awk -v s="$s" '{ print $s }'<<<$SMART_PARAMS)

		echo "Cheking /dev/$device with smart param $param"
                smartResult=$(smartctl -A -v 1,raw48:54 -v 7,raw48:54 /dev/$device | sed 's/^[[:space:]]*//' | sed 's/^0//' | sed -n -e "/^$param[[:space:]]/p" | awk '{ print $10 }')
		echo "smartResult: $smartResult"
		if [ -z $smartResult  ]; then 
			echo "Skipping /dev/$device with parameter $param because parameter is invalid or missing"
			continue 
		
		else 
			paramName=$(smartctl -A -v 1,raw48:54 -v 7,raw48:54 /dev/$device | sed 's/^[[:space:]]*//' | sed 's/^0//' | sed -n -e "/^$param[[:space:]]/p" | awk '{ print $2 }')
                	if [ $smartResult -gt ${deviceArray[$device,$param]} ]; then
                       	 	echo "smartResult: $smartResult prev: ${deviceArray[$device,$param]}"
                       	 	sendAlert $smartResult ${deviceArray[$device,$param]} $device $paramName
                       	 	deviceArray[$device,$param]=$smartResult
                	else
				echo "No changes. Value $paramName of /dev/$device is the same (${deviceArray[$device,$param]}) as previous"
                        	deviceArray[$device,$param]=$smartResult
                        	fi
		fi
		done
        done
}


echo "Getting block devices: $BLOCK_DEVICE"
echo "Getting S.M.A.R.T. attributes: $SMART_PARAMS"
while true
do
	iterateArray checkSmart BLOCK_DEVICE SMART_PARAMS
	date=$(getDate)
	echo "$date Sleep $CHECK_INTERVAL seconds"
	sleep $CHECK_INTERVAL

done
