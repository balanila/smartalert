# Simple disk S.M.A.R.T. checker with telegram alerts

## Installation

Smartalert requires awk to run.
Clone [github repo](https://github.com/balanila/smartalert.git "Project page on GitHub") or create files manually

# Create and edit docker_run.sh file

```sh
#!/bin/bash
SMART_PARAMS="1 5 10 187 123 177 178 179 240 241 242" #Write S.M.A.R.T. attrubutes space separated
TLGRM_TOKEN="0123456789:AABCD_186Bku5E8TCFaqBUx48jwkt5JbkA4" #Your telegram API Token
TLGRM_CHAT_ID="987654321" #Your chat ID
CHECK_INTERVAL="3600" #in seconds. Optional. By default interval = 1h
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
```

Necessary S.M.A.R.T. attributes you can find using smartctl command. 
It is recommended to use only critical attributes in order to avoid false messages
As example: check S.M.A.R.T. of /dev/sda disk:
```sh
smartctl -A /dev/sda
```
By default is used attr #5 (Reallocated_Sector_Ct)
You don't need to provide disk names. They will be detected and added automatically
Container checks your disk every $CHECK_INTERVAL. By default is 1 hour

Read [How To](https://core.telegram.org/bots#3-how-do-i-create-a-bot "Telegram HowTo") how to register a bot

# Create docker_stop.sh
```sh
#!/bin/bash
docker stop $(docker ps -q --filter name='smartalert' )
```

# Create docker_restart.sh
```sh
#!/bin/bash
docker stop $(docker ps -q --filter name='smartalert' )
./docker_run.sh
```

# Usage
- Start container using docker_run.sh
- To stop container use docker_stop.sh
- If your drives changed, just restart container using docker_restart.sh


