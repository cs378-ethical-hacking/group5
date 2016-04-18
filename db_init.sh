#!/bin/bash
clear

# function for quitting in error cases
function quit {
    printf "\n\t(╯°□°)╯︵ ┻━┻                 \n"
    printf "  ...hope this wasn't during the presentation...\n\n"
    exit
}


BANNER="
 █████╗ ██╗   ██╗████████╗ ██████╗ ███████╗ ██████╗ █████╗ ███╗   ██╗
██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔════╝██╔════╝██╔══██╗████╗  ██║
███████║██║   ██║   ██║   ██║   ██║███████╗██║     ███████║██╔██╗ ██║
██╔══██║██║   ██║   ██║   ██║   ██║╚════██║██║     ██╔══██║██║╚██╗██║
██║  ██║╚██████╔╝   ██║   ╚██████╔╝███████║╚██████╗██║  ██║██║ ╚████║
╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
                                                                     
"
printf "$BANNER"
#temporary title banner, for funsies

# detect active network interface
NIC=$(ip link show | grep 'state UP' | awk -F ': |:' '{print $2}')
if [[ "$NIC" == "" ]]
then
    echo "No active connections"
    quit
fi

#acquire and print out connection information
printf "Network Connection:\n"
CONNECT_INFO=$(iwconfig $NIC)
ESSID=$(echo $CONNECT_INFO | grep "ESSID" | awk -F ':"|"' '{print $2}')
MAC=$(echo $CONNECT_INFO | grep "Access Point" | awk -F ": | Bit" '{print $2}')
printf "+[$NIC]:\tESSID: $ESSID ($MAC)\n"

ifconfig $NIC down
macchanger -r $NIC
ifconfig $NIC up

#reconnect to network with new mac -- might be a better way this takes some time
nmcli con up id "$ESSID"

# checking on status of postgresql service
printf "checking database...\n"
CHECK=$(service postgresql status | grep dead)
if [[ "$CHECK" == "   Active: inactive (dead)" ]]; then
    printf "database inactive; enabling\n"
    service postgresql start
fi



# database initialization 
msfdb init
msfdb start

#launch metasploit with script file -- not yet implemented
#msfconsole -r msfc_footprint.rc