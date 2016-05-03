printf "[${BRIGHT}${MAGENTA}MySQL Bruteforce${NORMAL}]:\n"
msfconsole -r msfc_ssh_footprint.rc
rm -f $OUTFILE
