#!/bin/bash
TMP_FILE="/tmp/opp.txt"
if [ "$#" -lt "1" ]; then
    echo "ERROR: Not enough arguments passed, run with --help to get more info!"
    exit 1
fi

# Load the command and optional parameters
COMMAND=$1
PARAMETERS=$2

# Check if keystone is loaded
if [ -z "$OS_USERNAME" ] || [ -z "$OS_PASSWORD" ] || [ -z "$OS_AUTH_URL" ]; then
    echo "ERROR: Please load a keystone file or fill in the OS_USERNAME, OS_PASSWORD and OS_AUTH_URL variables!"
    exit 1
fi

# Check the connection by listing all projects
openstack project list --format csv | tail -n +2 > $TMP_FILE
if [ $? -ne 0 ]; then
    echo "ERROR: Could not communicate with OpenStack API, please check your credentitals!"
    exit 1
fi

# Check if single project exists, and delete resources and then project
if [ "$COMMAND" = "--single" ]; then
    echo "INFO: Purge starting!"
    grep "$PARAMETERS" $TMP_FILE > /dev/null
    if [ $? -eq 0 ]; then
        ospurge --purge-project $PARAMETERS --verbose
        if [ $? -eq 0 ]; then
            openstack project delete $PARAMETERS
        fi
    fi
    echo "INFO: Purge done!"
# Go trough all projects and remove all except admin or services
elif [ "$COMMAND" = "--all" ]; then
    echo "INFO: Purge starting!"
    while IFS=, read -r ID NAME
    do
        # Skip admin and services
        ID=`echo $ID | tr -d \"`
        NAME=`echo $NAME | tr -d \"`
        if [ "$NAME" = "admin" ] || [ "$NAME" = "services" ]; then
            continue
        fi
        # Purge the project
        ospurge --purge-project $NAME --verbose
        if [ $? -eq 0 ]; then
            # Before doing delete of project delete all of its users also
            openstack project delete $NAME
        else
            echo "ERROR: Purge failed for project $NAME"
        fi
    done < $TMP_FILE
    echo "INFO: Purge done!"
else
    echo "ERROR: Invalid command specified, check help for more info!"
fi

rm $TMP_FILE