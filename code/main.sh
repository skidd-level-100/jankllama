network_interface="wlp4s0"  # for ip address!
#"wlp5s0f4u1u2"
ip4=$(/sbin/ip -o -4 addr list $network_interface | awk '{print $4}' | cut -d/ -f1)

ngl=0  # gpu layers
temp=0.8 # temperture
threads=8 # cpu threads use only your core count for optimal speed
ctx=32768 # ctx size (this is set for mistral dolphin)
rpp=1.3 # repeat penalty, increase if the model repeats itself to much

main_path="$HOME/.llama/main" # path to your llama executable

model_path="$HOME/models/dolphin-2.6-mistral-7b.Q5_K_M.gguf" # path to your model

root_dir="/dev/shm/AI" # this is the folder used for storing files, you should keep it at default

cache_file="$root_dir/cache.bin" # where you want the context to be cached

chatloglive="$root_dir/chatloglive" # read the readme for this (it might not exist yet)

prompt_file="$HOME/.llama/prompts/calculator.txt" # prompt to use

notes_file="$HOME/.llama/interceptor/notes.txt" # the note function requires prompt engineering for the model to use it well (WIP)

writeablehome="/home/bumpsh/.llama/interceptor/writeable-home" # this will give the bots shell a writable folder to use inside of the container in /root

mkdir -p "$root_dir" # ensures folder(s) exist
mkdir -p "$HOME/.llama/prompts/" # ensures folder(s) exist

if [ -f "$chatloglive" ] && [ $(cat $chatloglive | wc -c) -gt 0 ]; then
echo "chatlog exists"
else
    echo "making chatlog"
    if [ -f "$prompt_file" ]; then
        cp "$prompt_file" "$chatloglive"
    else
        clear
        echo "NO PROMPT FILE FOUND IN : $prompt_file"
        exit
    fi

fi

check(){

# this function checks for function calls in the text on the final line


string=$( cat $chatloglive | sed -n $(( $(cat $chatloglive | wc -l) + 1))'p' ) # grabs last line into varable


cmd="" # sanatizing, just in case
cmd="$(echo "$string" | grep -Eo  "<read>.*</read>" | sed 's/<read>//g' | sed 's/<\/read>//g')" # if there is any text in the last line of context that is inbetween <read></read>

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
    take_input # lets user modify context file before passing it to model
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

# gets text between <shell> tags
cmd="$(echo "$string" | grep -Eo  "<shell>.*</shell>" | sed 's/<shell>//g' | sed 's/<\/shell>//g')" 


#if there is any text between the '<shell>' tags
if [ "$cmd" ]; then

# set up a container with the name of 'aibox' in podman or edit the command to your liking
cmd_output="$(timeout --kill-after=3s 3s podman run -v $writeablehome:/root:Z  --rm --read-only --memory 512m --cpus 1 aibox bash -c "source /root/.bashrc; $cmd" 2>&1 )"
remove "-v $writeablehome:/root:Z" to disable persistant writable storage
if [ "$cmd_output" == "" ]; then
cmd_output="none" # most of the time non output means the command worked, but since I have know way of knowing that for sure I set it to "none" not "success"
fi


#write command output to prompt (context file)
echo -e "\n 

system
command output:
$cmd_output

bot
" >> "$chatloglive"
fi

cmd=""
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

cmd=""
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

}

take_input(){
#lets user modify context (prompt)


# caches the chatlog into input file
cp "$chatloglive" "$root_dir/input"

echo -e "\n user\ntime of message:\n $(date +"%r")\n message: \n" >> "$root_dir/input" # appends "user" and time into input before you take over

$EDITOR "$root_dir/input" # opens your systems editor on the prompt file
echo -e "\nbot\n" >> "$root_dir/input" # after you close your editor it appends bot to the end in order to prompt it to respond
mv "$root_dir/input" "$chatloglive" # moves input back where it belongs

}


take_input # takes inital input, remove or comment out if you want the bot to speak first
while true; do

cp "$chatloglive" "$root_dir/currentchatlog" # backs up the file that will be written to
rm "$chatloglive" # removes the file to be written to
touch "$chatloglive" # re-creates it to be sure
# the '| tee -a' part of the command appends all of the prompt back into "$chatloglive"
$main_path --ignore-eos --no-penalize-nl -t $threads -m $model_path --color  -r "</calc>" -r "</note>" -r "</read>"  -r "</shell>" -c $ctx --temp $temp --repeat_penalty $rpp -n -1 -p "$(cat "$root_dir/currentchatlog")" --log-disable -ngl $ngl --prompt-cache "$cache_file " | tee -a "$chatloglive"
check # checks for function tags
done
