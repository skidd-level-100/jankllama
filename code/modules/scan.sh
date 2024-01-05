string=""
export string="$( cat "$chatloglive" | sed -n $(( $(cat $chatloglive | wc -l) + 1))'p' )" # last line into varable

# for useful comment read each funtions file

bash $modules_path/function_read.sh

bash $modules_path/function_shell.sh

bash $modules_path/function_calc.sh

bash $modules_path/function_note.sh

bash $modules_path/example_module.sh