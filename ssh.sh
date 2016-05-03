printf "[${BRIGHT}${MAGENTA}MySQL Bruteforce${NORMAL}]:\n"
OUTFILE="arp-scan.xml"
nmap -p22 $ARPRESULT -oX $OUTFILE
msfconsole -r msfc_ssh_footprint.rc
rm -f $OUTFILE