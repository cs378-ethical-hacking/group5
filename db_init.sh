#!/bin/bash

clear

echo "checking database..."
CHECK=$(service postgresql status | grep dead)
if [[ "$CHECK" == "   Active: inactive (dead)" ]]; then
    echo "database inactive; enabling"
    service postgresql start
fi
msfdb init
msfdb start
msfconsole -r msfc_footprint.rc