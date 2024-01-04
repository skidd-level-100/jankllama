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
this is all it is used for, nothing else

# I need help on ____________
make an issue, ill try to get back to it and keep in mind this is VERY VERY VERY alpha.

# Windows support
no, never I have enough problems trying to git push I dont need to deal with that junk.
