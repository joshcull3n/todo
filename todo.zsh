#!/usr/bin/env zsh

SCRIPT_DIR="${0:A:h}"
. "$SCRIPT_DIR/src/functions.zsh"

FILE_DIR=~/.todos
FILE_TASKS=$FILE_DIR"/todos.txt"

# constants #
REPEAT_CHAR=" ~"
PROG_SYMBOL="✎"
WINDOW_WIDTH=$(tput cols)
WINDOW_HEIGHT=$(tput lines)

clear

# first time check #
if [[ ! -d $FILE_DIR ]]; then
  FIRST_TIME=0
  mkdir $FILE_DIR
elif [[ ! -e $FILE_TASKS ]]; then
  FIRST_TIME=0
fi

touch $FILE_TASKS
resizeWindow
readTasks

# commands #
if [[ $# -ne 0 ]]; then
  COMMAND=$1
  shift
  case $COMMAND in
    add|a)      addTask "$*" ;; # add task to todo list
    bottom|b)   moveTaskBottom "$*" ;; # move task to bottom of list
    clear)      clearTasks "$*" ;; # clear all tasks
    done|d)     completeTask "$*" ;; # mark task as complete by index
    delete|del) deleteTask "$*" ;; # delete task by index
    get|g)      getTaskDetails "$*" ;; # get task details by index
    list|l)     listTasks ;; # list tasks
    prog|p)     progTask "$*" ;; # set task as currently in progress
    undo|u)     undoTask "$*" ;; # set done task to new by index
    top|t)      moveTaskTop "$*" ;;
    *)          unrecognized ;;
  esac
fi

commitTasks
readTasks

if [[ $FIRST_TIME ]]; then
    sendMessage "this looks like your first time running todo! i have" "created a file in ~/.todos/todos.txt to store your" "tasks."
else
  listTasks
  echo ""
fi
