#!/bin/bash
APP_NAME=$1
ARGOCD="/opt/homebrew/bin/argocd"
TIMEOUT=120 

get_health_status() {
    echo "$(${ARGOCD} app get ${APP_NAME} | grep -i 'Health Status' | awk '{print $3}')"
}

get_sync_status() {
    echo "$(${ARGOCD} app get ${APP_NAME} | grep -i 'Sync Status' | awk '{print $3}')"
}

print_app_logs() {
    echo "Fetching logs for application ${APP_NAME}..."
    ${ARGOCD} app logs ${APP_NAME}
}

rollback_app() {
    echo "Rolling back ${APP_NAME} to the previous commit..."
    ${ARGOCD} app rollback ${APP_NAME}
}

while true; do
    APP_HEALTH_STATUS=$(get_health_status)
    APP_SYNC_STATUS=$(get_sync_status)

    if [ "${APP_SYNC_STATUS}" != "Synced" ]; then
        echo "Application ${APP_NAME} is out of sync. Starting sync..."
        ${ARGOCD} app sync ${APP_NAME} -o tree=detailed
    fi

    echo "Waiting for application ${APP_NAME} to become healthy..."
    ${ARGOCD} app wait ${APP_NAME} --health --timeout ${TIMEOUT}


    APP_HEALTH_STATUS=$(get_health_status)
    
    if [ "${APP_HEALTH_STATUS}" == "Healthy" ]; then
        echo "Application ${APP_NAME} is healthy."
        break

    elif [ "${APP_HEALTH_STATUS}" == "Degraded" ] || [ "${APP_HEALTH_STATUS}" != "Healthy" ]; then
        echo "Application ${APP_NAME} is unhealthy with status: ${APP_HEALTH_STATUS}"
        print_app_logs  
        rollback_app  
        echo "Application Deployment failed with Current Status: ${APP_SYNC_STATUS}"
        exit 1 

    else
        echo "Application ${APP_NAME} is still not healthy. Health status: ${APP_HEALTH_STATUS}"
    fi

    sleep 10 
done
