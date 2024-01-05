#!/bin/bash -x
cmd="$(echo "$string" | grep -Eo  "<nuke>.*</nuke>" | sed 's/<nuke>//g' | sed 's/<\/nuke>//g')"

if [ "$cmd" ]; then 

    if [ "$cmd" == "USA" ]; then
        cmd_output="You may not nuke the homeland."
    else
        cmd_output="You have just nuked $cmd"
    fi

echo -e "\n 

system
Nuke status:
$cmd_output 

bot\n " >> "$chatloglive"

fi