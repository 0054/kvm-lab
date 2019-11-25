#!/bin/bash

function runScript {
    CSRF_TOKEN=`curl -s http://${JENKINS_USER}:${JENKINS_API_TOKEN}@${JENKINS_SERVER}/crumbIssuer/api/json | python -c '
import sys,json
a=json.loads(sys.stdin.read())
print "{}={}".format(a["crumbRequestField"],a["crumb"])'`
    curl --user ${JENKINS_USER}:${JENKINS_API_TOKEN} -d "$CSRF_TOKEN" --data-urlencode "script=$( < $SCRIPT )" http://${JENKINS_SERVER}/scriptText
}

SCRIPT=$1
if [ -f $SCRIPT ]; then
    if [ -z $JENKINS_API_TOKEN ] && [ -z $JENKINS_USER ] && [ -z $JENKINS_SERVER ]; then
        JENKINS_API_TOKEN=
        JENKINS_USER=admin
        JENKINS_SERVER=10.10.1.12
        runScript
    else
        runScript
    fi
else
    echo $SCRIPT No such file
    exit 1
fi

