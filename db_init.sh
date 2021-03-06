#!/bin/bash
clear
source emoji_and_colors.sh

# function for quitting in error cases
function quit {
    printf "\n\t  ${BLUE}(╯${CYAN}°${WHITE}□${CYAN}°${BLUE})╯${NORMAL}︵ ${RED}┻━┻${NORMAL}\n"
    printf "  ...hope this wasn't during the presentation...\n\n"
    exit
}

#   is_zero string msg
# if argument $1 is empty, print arg $2 as an error message
function is_empty {
    if [[ -z $1 ]]
    then
        printf "${RED_BG}${BRIGHT}ERROR:${NORMAL} $2 \n"
        quit
    fi
}

BANNER="
${YELLOW}  █████╗ ██╗   ██╗████████╗ ██████╗ ███████╗ ██████╗ █████╗ ███╗   ██╗
${GREEN} ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔════╝██╔════╝██╔══██╗████╗  ██║
${CYAN} ███████║██║   ██║   ██║   ██║   ██║███████╗██║     ███████║██╔██╗ ██║
${BLUE} ██╔══██║██║   ██║   ██║   ██║   ██║╚════██║██║     ██╔══██║██║╚██╗██║
${MAGENTA} ██║  ██║╚██████╔╝   ██║   ╚██████╔╝███████║╚██████╗██║  ██║██║ ╚████║
${RED} ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝
${NORMAL}                                                                     
"
printf "$BANNER"

# detect active network interface
NIC=$(ip link show | grep 'state UP' | awk -F ': |:' '{print $2}')
is_empty "$NIC" "no available network connection"

#acquire and print out connection information
printf "Network Connection:\n"
CONNECT_INFO=$(iwconfig $NIC)
ESSID=$(echo $CONNECT_INFO | grep "ESSID" | awk -F ':"|"' '{print $2}')
MAC=$(echo $CONNECT_INFO | grep "Access Point" | awk -F ": | Bit" '{print $2}')
printf "+[${GREEN}$NIC${NORMAL}]:  ${BRIGHT}ESSID:${NORMAL} ${CYAN}$ESSID${NORMAL} (${MAGENTA}$MAC${NORMAL})\n"
printf "${BRIGHT}=====================================================================${NORMAL}\n"
#ifconfig $NIC down
#macchanger -r $NIC
#ifconfig $NIC up

# #reconnect to network with new mac -- might be a better way this takes some time
#if [ $( echo $NIC | grep wlan ) != "" ]; then
#    nmcli con up id "$ESSID"
#fi

# arp scan parsing: returns a list of space-separated IPs
ARPRESULT=$(arp-scan --localnet | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | tr '\n' ' ')
# error check
is_empty "$ARPRESULT" "ARP scan failure"
printf "+[${GREEN}HOSTS${NORMAL}]: ${YELLOW}$ARPRESULT${NORMAL}\n\n"
#remove trailing space 
ARPRESULT=${ARPRESULT:0:-1}

# turn string into array for individual host scanning
HOSTS=($ARPRESULT)

# execute NFS script
source nfs.sh

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

source mysql.sh
source ssh.sh

printf "YAY WE DID IT!\t$EM_GIFFKISS\n"
