#!/bin/bash

#Check for root permissions

if [[ "${UID}" -ne 0 ]]
then
    echo "Please execute this script with sudo / root permissions"
    exit 1
fi

# LogFile
LOG_FILE="logfile.txt"

#Check if ntp service is turned on :
NTP_ACTIVE=$(timedatectl status | grep "NTP service" | awk '{print $3}')
if [[ ${NTP_ACTIVE} != "active" ]]
then
    timedatectl set-ntp true
    if [[ ${?} -ne 0 ]]
    then
        echo "NTP could not be enabled" &>>${LOG_FILE}
        exit 1
    fi
fi

sleep 3

timedatectl set-ntp false

sleep 3

# Get the input for time to run
CURRENT_TIME=$(timedatectl | grep "Local time" | awk '{print $5}')
REQUIRED_TIME=$(date '+%T' --date="${CURRENT_TIME} IST + 10 seconds")
timedatectl set-time ${REQUIRED_TIME}

if [[ "${?}" -ne 0 ]]
then
    echo "Error occured during setting the time" &>>${LOG_FILE}
    exit 1
else
    echo "Time set successfully" &>>${LOG_FILE}
fi

if [[ ${NTP_ACTIVE} == "active" ]]
then
    timedatectl set-ntp false &>>${LOG_FILE}
    if [[ ${?} -ne 0 ]]
    then
        echo "NTP could not be disabled" &>>${LOG_FILE}
        exit 1
    fi
fi