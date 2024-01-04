# jankllama
A janky lil bash script to add function calling to your LLM, built for https://github.com/ggerganov/llama.cpp


# set up

## dependances
- bc 
    - for math
- podman
    - for the LLM's shell
- bash
    - duh

# settings
edit the code/main.sh file, inside you will find varables set each one to the correct value for your system, model path, prompt path, etc
list of settings:
```bash
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

prompt_file="$HOME/.llama/prompts/calculator.txt" # prompt to use

export notes_file="$HOME/.llama/interceptor/notes.txt" # the note function requires prompt engineering for the model to use it well (WIP)

export writeablehome="/home/bumpsh/.llama/interceptor/writeable-home" # this will give the bots shell a writable folder to use inside of the container in /root

export input="$root_dir/input" # where user input in temporarly stored

```
just set these to the appropriate path/value


## setting up a shell for your bot
- learn podman (basically same as docker syntax but lighter and more secure)
    - learn how to make a podman container
        - make a container
            - setup the container with tools you want
                - commit the container to the name 'aibox'

- modify podmans launch options in 'code/modules/function_shell.sh'
    - if you want to you can replace the 'podman' section of the command with 'docker' and in *theory* it will work fine.
- for docker mains
    - podman networks are different than docker, that you will need to look into

## but why does it need my network interface?
inside of "modules/function_read.sh" you will find:

```bash
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

```

you will see on the secound 'elif' that there is a section of the function that scans your network using nmap, this needs your LAN ip address.
the model when it runs '<read>nmap</read>' can the look through your LAN

# I need help on ____________
make an issue, ill try to get back to it and keep in mind this is VERY VERY VERY alpha, and a random project made on a whim.

# Windows support
no, never, I have enough problems trying to git push I don't need to deal with that junk.
    
- you may try WSL or a VM

# Making a module (function)

[guide here!](docs/modules.md)