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

# constants #
REPEAT_CHAR=" ~"
TODO_SYMBOL="·"


# prep vars #
touch $FILE_TASKS
TASKS=$(<$FILE_TASKS)
TASKS_ARR=("${(f)TASKS}")
TASK_DISPLAY_NAMES_ARR=()
TOTAL_TASKS=1
WINDOW_WIDTH=$(tput cols)
WINDOW_HEIGHT=$(tput lines)



# functions #
addTask () {
  echo -n $TOTAL_TASKS"|"$1"|NEW|\n" >> $FILE_TASKS
  echo added task \'$*\' as task number $TOTAL_TASKS!
}

listTasks () {
  echo ""
  fillWidthChars " > todos"
  if [[ $TOTAL_TASKS -eq 1 ]]; then
    echo "\n   you don't have any todos!\n"
  fi
  for taskName in $TASK_DISPLAY_NAMES_ARR
  do
    echo "  "$taskName
  done
  echo ""
}

# first argument is input string
fillWidthChars () {
  outString=$1
  repeat_count=$((($WINDOW_WIDTH-${#outString}-1)/2))
  for i in {1..$repeat_count}; do
    outString="$outString$REPEAT_CHAR"
  done
  echo $outString
}

resizeWindow () {
  clear
  printf '\e[8;51;64t'
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
    TASK_DISPLAY_NAMES_ARR+=" ["$parseString[1]"] $TODO_SYMBOL "$parseString[2]
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
    resize) resizeWindow ;; # resize to ideal todo list size
  esac
else
  listTasks
fi
