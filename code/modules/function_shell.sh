# gets text between <shell> tags

cmd="$(echo "$string" | grep -Eo  "<shell>.*</shell>" | sed 's/<shell>//g' | sed 's/<\/shell>//g')" 


#if there is any text between the '<shell>' tags
if [ "$cmd" ]; then
# set up a container with the name of 'aibox' in podman or edit the command to your liking
cmd_output="$(timeout --kill-after=3s 3s podman run -v $writeablehome:/root:Z  --rm --read-only --memory 512m --cpus 1 aibox bash -c "source /root/.bashrc; $cmd" 2>&1 )"

remove "-v $writeablehome:/root:Z" to disable persistant writable storage

if [ "$cmd_output" == "" ]; then

cmd_output="none" # most of the time non output means the command worked, but since I have know way of knowing that for sure I set it to "none" not "success"

#write command output to prompt (context file)
echo -e "\n 

system
command output:
$cmd_output

bot
" >> "$chatloglive"
fi

fi