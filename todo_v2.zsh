#!/usr/bin/env zsh

SCRIPT_DIR="${0:A:h}"
. "$SCRIPT_DIR/src/functions_v2.zsh"

# ensure tasks.txt exists
FILE_DIR=~/.todos/test
FILE_TASKS=$FILE_DIR"/tasks.txt"

# first time #
if [[ ! -d $FILE_DIR ]]; then
  echo "this looks like your first time running todo!"
  echo "i have created a todo.txt file in a hidden folder (~/.todos) to store your todos!"
  mkdir $FILE_DIR
fi

# constants #
REPEAT_CHAR=" ~"
TODO_SYMBOL="·"
DONE_SYMBOL="x"
PROG_SYMBOL="✎"
WINDOW_WIDTH=$(tput cols)
WINDOW_HEIGHT=$(tput lines)

touch $FILE_TASKS

unrecognized () {
  #listTasks
  echo "                    > Unrecognized command. Usage:"
  echo "                    > td {list|add|done|delete|...} {flags|task}"
  echo "                    > See help for more."
}

clear
resizeWindow
readTasks

# commands #
if [[ $# -ne 0 ]]; then
  COMMAND=$1
  shift
  case $COMMAND in
    add|a)      addTask "$*" ; listTasks;; # add task to todo list
    #bottom|b)   bottomTask "$*" ;; # move task to bottom of list
    #clear)      clearTasks "$*" ;; # clear all tasks
    done|d)     completeTask "$*" ; listTasks;; # mark task as complete by index
    delete|del) deleteTask "$*" ;; # delete task by index
    list|l)     listTasks ;; # list tasks
    #prog|p)     progTask "$*" ;; # set task as currently in progress
    #undo|u)     undoTask "$*" ;; # set done task to new by index
    #resize)     resizeWindow ; listTasks;; # resize window to ideal todo list size
    #top|t)      topTask "$*" ;;
    *)          unrecognized ;;
  esac
else
  listTasks
fi

commitTasks