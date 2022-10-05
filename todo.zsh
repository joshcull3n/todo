#!/usr/bin/env zsh

SCRIPT_DIR="${0:A:h}"
. "$SCRIPT_DIR/src/functions.zsh"

# ensure tasks.txt exists
FILE_DIR=~/.todos
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
DONE_SYMVOL="x"

touch $FILE_TASKS

# refresh variables every time the script is run
initTasks

# commands #
if [[ $# -ne 0 ]]; then
  COMMAND=$1
  shift
  case $COMMAND in
    add|a) addTask "$*" ;; # add task to todo list
    list|l) listTasks ;; # list tasks
    resize) resizeWindow ;; # resize window to ideal todo list size
    done|d) completeTask "$*";; # mark task as complete
    clear) clearTaskFile ;;
  esac
else
  listTasks
fi
