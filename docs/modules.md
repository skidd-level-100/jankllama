# making your own module!

modules are executed when the tag is detected in the output, and then passes the modified prompt back to the LLM

EX:
```
bot
I want to nuke Russia! using the nuke tag
<nuke>Russia</nuke>
```
then your script takes over and may modify the output as it likes


first think of a good tag name like "\<nuke\>"

# varables
The main.sh will have given you a varable called "string" this is the bottom line of the llama.cpp's output
another varable to use is "chatloglive" this is the output that will be passed back into the model as a prompt

# example module
make a file in code/modules, for this example I will make a example_module.sh

for the first line ill choose to put:

```bash
cmd="$(echo "$string" | grep -Eo  "<nuke>.*</nuke>" | sed 's/<nuke>//g' | sed 's/<\/nuke>//g')"
```

this will grab all text between the tag that you have made and become the variable "cmd"

```bash
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

else
echo -e "\n 

system
Nuke status:
No location provided

bot\n " >> "$chatloglive"

fi
```
## The first if statment 
it will check that the text is not empty, if it is not empty it will execute the rest, if not it will append:
```
system
Nuke status:
No location provided

bot
```
to the bots context (prompt)

## The secound if statement
it will check if the target is 'USA'
basically if 
```
<nuke>USA</nuke>
```
is there it will set the output of the function to:

```
You may not nuke the homeland.
```

if any other word is in there is this case we will use:
```
<nuke>Russia</nuke>
```
it will set the output to:
```
You have just nuked Russia
```

## the echo part

this will append the function output into the models context (prompt) like this
```
system
Nuke status:
FUNCTION OUTPUT HERE

bot

```

now open 'code/main.sh' and towards the bottom find the part that runs llama, the add a launch option of '-r "\</nuke\>" '
after that add your script into code/modules/scan.sh, at the bottom
```bash
bash $modules_path/FUNCTION_NAME.sh
```


__I have not tested this in action, so there might be code mistakes.__