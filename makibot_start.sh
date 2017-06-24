#!/bin/bash

export HUBOT_SLACK_TOKEN=xoxb-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export HUBOT_GOOGLE_CSE_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export HUBOT_GOOGLE_CSE_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

forever start -c coffee node_modules/.bin/hubot --adapter \slack
