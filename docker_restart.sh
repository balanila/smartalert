#!/bin/bash
docker stop $(docker ps -q --filter name='smartalert' )
sleep 5
./docker_run.sh
