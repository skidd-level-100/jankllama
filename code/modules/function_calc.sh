# grabs anything between '<calc>' tags and puts it into the cmd varable
cmd="$(echo "$string" | grep -Eo  "<calc>.*</calc>" | sed 's/<calc>//g' | sed 's/<\/calc>//g')"

# if it has anything in the varable then run it through the 'bc' command
if [ "$cmd" ]; then

# change "scale" to however many decimals you want to be calculated to.
cmd_output="$(bc -l  <<< "scale=6; $cmd" 2>&1)"
#writes the answer into prompt (context file)
echo -e "\n 

system
calculated to be:
$cmd_output 

bot\n " >> "$chatloglive"
fi
