#!/bin/bash
clear

# function for quitting in error cases
function quit {
    printf "\n\t  (╯°□°)╯︵ ┻━┻                 \n"
    printf "  ...hope this wasn't during the presentation...\n\n"
    exit
}

#   is_zero string msg
# if argument $1 is empty, print arg $2 as an error message
function is_empty {
    if [[ -z $1 ]]
    then
        printf "ERROR: $2 \n"
        quit
    fi
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
is_empty $NIC "no available network connection"

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

# arp scan parsing: returns a list of space-separated IPs
ARPRESULT=$(arp-scan --localnet | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | tr '\n' ' ')
# error check
is_empty $ARPRESULT "ARP scan failure"
#remove trailing space 
ARPRESULT=${ARPRESULT:0:-1}

# turn string into array for individual host scanning
HOSTS=($ARPRESULT)

# nmap output file
OUTFILE="arp-scan.378"


# sample nmap scan using arp-scan result 
#nmap -Pn -p5357 ${HOSTS[1]} > $OUTFILE

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