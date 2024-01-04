# grabs any text between "<note>" tags into a varable 
cmd="$(echo "$string" | grep -Eo  "<note>.*</note>" | sed 's/<note>//g' | sed 's/<\/note>//g')"

#if there is any text, write it to the "$notes_file" file along with the date and time written
if [ "$cmd" ]; then
    echo -e "\n  $(date) \n $cmd" >> $notes_file
    cmd_output="new note written"
#  write into prompt that the command worked
echo -e "\n 

system
note status:
$cmd_output 

bot\n" >> "$chatloglive"
fi
