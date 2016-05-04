# AUTOSCAN

Targets: NFS, SSH, MySQL services

Methodology:
1. enumerate hosts (arp-scan --localnet parse)

2. initialize and connect to PostgreSQL database

3. create list of hosts to pass into db_nmap

4. pass msfconsole scripts in sequentially for each attack.


usage: ./db_init.sh when connected to the desired target network
