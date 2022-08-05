#!/bin/bash

remote_list=$(rclone rc config/listremotes | jq --raw-output '.remotes[]')

while :
    do
        for remote in $remote_list
        do
            type=$(rclone rc config/get name=$remote | jq --raw-output '.type')
            echo $type
            if [[ "$type" = "drive" ]]; then
                echo "Modifying service accounts for - ${remote}"
                SERVICE_ACCOUNT_KEY=$(curl ${SERVICE_ACCOUNT_BLACKLIST_ENDPOINT}/get/${DOCKER_SERVICE_NAME} | jq --raw-output '.service_account')
                rclone rc backend/command command=set fs=${remote}: -o service_account_file=/service_account_keys/${SERVICE_ACCOUNT_KEY}
                # Blacklist the key for one hour
                key_to_blacklist=$(rclone rc backend/command command=get fs=${remote}: -o service_account_file | jq --raw-output '.result.service_account_file')
            else
                echo "Skipping as it is either a union or other non supported mount to rotate. Only manipulate Google Drive Mounts."
            fi
        done 
        sleep ${SERVICE_ACCOUNT_ROTATE_SLEEP}
    done
