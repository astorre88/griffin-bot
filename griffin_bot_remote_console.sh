#!/bin/sh

docker exec -it $(docker ps | grep griffin_bot_web_1 | awk '{print $1}') bin/griffin_bot remote_console
