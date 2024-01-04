
#lets user modify context (prompt) when called


# caches the chatlog into input file
cp "$chatloglive" "$input"

echo -e "\n user\ntime of message:\n $(date +"%r")\n message: \n" >> "$input" # appends "user" and time into input before you take over

$EDITOR "$input" # opens your systems editor on the prompt file
echo -e "\nbot\n" >> "$input" # after you close your editor it appends bot to the end in order to prompt it to respond
mv "$input" "$chatloglive" # moves input back where it belongs