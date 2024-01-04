 # get text if there is any text in the last line of context that is inbetween <read></read>
cmd="$(echo "$string" | grep -Eo  "<read>.*</read>" | sed 's/<read>//g' | sed 's/<\/read>//g')"
# if any text was found
if [ "$cmd" ]; then 

noreadoutput=false # this is here to set wether or not to edit the file at the end.

# if the text = 'X', then run 'Y' and pass the output into the ctx file
if [ "$cmd" == "notes" ]; then
    cmd_output="$(cat $notes_file)"
    output_label="notes:"
elif [ "$cmd" == "time" ]; then
    cmd_output="$(date)"
    output_label="current date and time:"
elif [ "$cmd" == "nmap" ]; then
    cmd_output="$(nmap --host-timeout 0.5 "$ip4"/24)"
    output_label="network scan results:"
elif [ "$cmd" == "userinput" ]; then
    string="" #more sanatizing
    cmd="" #more sanatizing
    noreadoutput=true # have no automated effect on prompt
    bash $modules_path/input.sh "$chatloglive" "$root_dir/input" # lets user modify context file before passing it to model
else
    cmd_output="error bad value" # if your bot sucks
fi

#assuming you didnt set your command to have no automated effect on the prompt output, write to context file
if [ $noreadoutput == false ]; then 
echo -e "\n 

system
$output_label
$cmd_output 

bot\n" >> "$chatloglive"

fi

fi