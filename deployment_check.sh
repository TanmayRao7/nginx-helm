#!/bin/bash
DEPLOYMENT_NAME=$1
KUBECTL="/opt/homebrew/bin/kubectl"
${KUBECTL} events --for deployment/${DEPLOYMENT_NAME} -w &
EVENTS_PID=$!
while true
do
    ROLLOUT_STATUS=$(${KUBECTL} rollout status deployment/${DEPLOYMENT_NAME} | awk '{print $3}')
    
    if [ "${ROLLOUT_STATUS}" == "successfully" ]; then
        echo "Deployment is successful"
        kill $EVENTS_PID
        break
    else
        echo "Waiting for deployment to complete..."
        sleep 2
    fi
done
