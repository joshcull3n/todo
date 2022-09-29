#!/usr/bin/env zsh

# ensure tasks.txt exists
FILE_DIR=./.todos
FILE_TASKS=$FILE_DIR"/tasks.txt"

# first time #
if [[ ! -d $FILE_DIR ]]; then
  echo "this looks like your first time running todo!"
  echo "i have created a todo.txt file in a folder (.todos) to store your todos!"
  mkdir $FILE_DIR
fi

# prep vars #
touch $FILE_TASKS
TASKS=$(<$FILE_TASKS)
TASKS_ARR=("${(f)TASKS}")
TASK_DISPLAY_NAMES_ARR=()
TOTAL_TASKS=1



# functions #
addTask () {
  echo -n $TOTAL_TASKS"|"$1"|NEW|\n" >> $FILE_TASKS
  echo added task \'$*\' as task number $TOTAL_TASKS!
}

listTasks () {
  echo ""
  echo "   todos ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"
  for taskName in $TASK_DISPLAY_NAMES_ARR
  do
    echo "  "$taskName
  done
  echo ""
}

setVars () {
  TASKS=$(<$FILE_TASKS)
  TASKS_ARR=("${(f)TASKS}")
  
  # parse task name from each task and update total num
  TASK_DISPLAY_NAMES_ARR=()
  for task in $TASKS_ARR
  do
    ((TOTAL_TASKS++))
    parseString=("${(@s/|/)task}")
    TASK_DISPLAY_NAMES_ARR+=" ["$parseString[1]"] o  "$parseString[2]
  done
}

help () {
  echo help meeeeee
}

# refresh variables every time the script is run
setVars

# commands #
if [[ $# -ne 0 ]]; then
  COMMAND=$1
  shift
  case $COMMAND in
    add|a) addTask "$*" ;; # add task to todo list
    list|l) listTasks  ;;  # list tasks 
  esac
else
  listTasks
fi
