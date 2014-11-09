#!/bin/bash

ADDR=http://127.0.0.1:3000
function wait_for_foxserver {
    RESPONSE=$(curl -s ${ADDR})
    echo -n "RESPONSE: ${RESPONSE}  >> "
    if [ $(echo ${RESPONSE}|grep -c status) -eq 1 ];then
        STATUS=$(curl -s ${ADDR}| python -c 'import sys,json;data=json.loads(sys.stdin.read()); print data["status"]')
        echo "STATUS: ${STATUS}"
        if [ "X${STATUS}" != "XOK" ];then
            sleep 5
            wait_for_foxserver
        fi
    else
        sleep 5
        wait_for_foxserver
    fi
}


wait_for_foxserver
curl -XPOST ${ADDR}/complete
exit $?
