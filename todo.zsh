#!/usr/bin/env zsh

SCRIPT_DIR="${0:A:h}"
. "$SCRIPT_DIR/src/functions.zsh"

# ensure tasks.txt exists
FILE_DIR=~/.todos
FILE_TASKS=$FILE_DIR"/tasks.txt"

# first time #
if [[ ! -d $FILE_DIR ]]; then
  echo "this looks like your first time running todo!"
  echo "i have created a todo.txt file in a hidden folder (~/.todos) to store your todos!"
  mkdir $FILE_DIR
fi

# constants #
REPEAT_CHAR=" ~"
PROG_SYMBOL="✎"
WINDOW_WIDTH=$(tput cols)
WINDOW_HEIGHT=$(tput lines)

touch $FILE_TASKS

clear
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
    list|l)     listTasks ;; # list tasks
    prog|p)     progTask "$*" ;; # set task as currently in progress
    undo|u)     undoTask "$*" ;; # set done task to new by index
    top|t)      moveTaskTop "$*" ;;
    *)          unrecognized ;;
  esac
fi

commitTasks
readTasks
listTasks
