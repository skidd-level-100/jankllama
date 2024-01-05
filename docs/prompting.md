# so I have a module, how do I prompt?
your goal is to get your model to repeatedly use your tag properly, so simply give it a pattern to follow.


```
system
a bot that says nothing but "if you dont get it by now leave now <read>userinput</read>"

user
hello?

bot
if you dont get it by now leave now <read>userinput</read>

user
get what?

bot
if you dont get it by now leave now <read>userinput</read>

user
u gey

bot
if you dont get it by now leave now <read>userinput</read>
```
if you have the bot use this as the prompt (most) bots will keep this pattern if the temp is low.

for a nuke prompt see [example.txt](../code/prompts/example.txt)

this is a joke one so I have not tested it that well yet.