script_path="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # grabs the directory that the main.sh file is located in
export script_path="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # grabs the directory that the main.sh file is located in

#settings here!
export modules_path="$script_path/modules" # where the script will find modules
export network_interface="wlp4s0"  # for LAN ip address!
export ip4=$(/sbin/ip -o -4 addr list $network_interface | awk '{print $4}' | cut -d/ -f1)

ngl=0  # gpu layers
temp=0.8 # temperture
threads=8 # cpu threads use only your core count for optimal speed
ctx=32768 # ctx size (this is set for mistral dolphin)
rpp=1.3 # repeat penalty, increase if the model repeats itself to much

main_path="$HOME/.llama/main" # path to your llama executable

model_path="$HOME/models/dolphin-2.6-mistral-7b.Q5_K_M.gguf" # path to your model

export root_dir="/dev/shm/AI" # this is the folder used for storing files, you should keep it at default

cache_file="$root_dir/cache.bin" # where you want the context to be cached

export chatloglive="$root_dir/chatloglive" # read the readme for this (it might not be documented yet)

prompt_file="$script_path/prompts/example.txt" # prompt to use

export notes_file="$HOME/.llama/interceptor/notes.txt" # the note function requires prompt engineering for the model to use it well (WIP)

export writeablehome="/home/bumpsh/.llama/interceptor/writeable-home" # this will give the bots shell a writable folder to use inside of the container in /root

export input="$root_dir/input" # where user input in temporarly stored
#end of settings


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
# any script put in here will be executed after the LLM finishes generation
bash "$modules_path/scan.sh"
}



bash $modules_path/input.sh "$chatloglive" "$root_dir/input" # takes inital input, remove or comment out if you want the bot to speak first
while true; do

cp "$chatloglive" "$root_dir/currentchatlog" # backs up the file that will be written to
rm "$chatloglive" # removes the file to be written to
touch "$chatloglive" # re-creates it to be sure
# the '| tee -a' part of the command appends all of the prompt back into "$chatloglive"
$main_path --ignore-eos -t $threads -m $model_path --color  -r "</calc>" -r "</note>" -r "</nuke>" -r "</read>"  -r "</shell>" -c $ctx --temp $temp --repeat_penalty $rpp -n -1 -p "$(cat "$root_dir/currentchatlog")" --log-disable -ngl $ngl --prompt-cache "$cache_file " | tee -a "$chatloglive"
check # checks for function tags
done
