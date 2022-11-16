# functions #

# add task to main list
addTask () {
  NEW_TASKS+=$1
  rectifyTasks
  listTasks
}

# ask "are you sure?"
confirmation () {
  vared -p "  > Are you sure? (y/N): " -c input
  if [[ ("$input" == "y") || ("$input" == "Y") ]]; then
    input="y"
  else
    input="n"
  fi
  echo "$input"
}

clearDoneTasks () {
  DONE_TASKS=()
  rectifyTasks
  listTasks
}

clearTaskFile () {
  echo -n > $FILE_TASKS
}

# takes number as input
completeTask () {
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    doneTask=$NEW_TASKS[$1]
    parsedTask=("${(@s/|/)doneTask}") # in case task is in progress, parse it by "|"
    DONE_TASKS+=$parsedTask[1]
    NEW_TASKS=("${NEW_TASKS[@]:0:$1-1}" "${NEW_TASKS[@]:$1}")
    if [[ $doneTask == $PROG_TASK ]]; then
      PROG_TASK=""
    fi
    rectifyTasks
    listTasks
  else
    echo "please specify task index, not name!"
  fi
}

deleteTask () {
  lenNew=${#NEW_TASKS[@]}
  lenDone=${#DONE_TASKS[@]}

  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    task=$TASKS_ARR[$1]
    if [[ $1 -le $lenNew ]]; then
      NEW_TASKS=("${NEW_TASKS[@]:0:$1-1}" "${NEW_TASKS[@]:$1}") 
    elif [[ $1 -le (($lenDone+$lenNew)) ]]; then
      doneIndex=$(($1-$lenNew))
      DONE_TASKS=("${DONE_TASKS[@]:0:$doneIndex-1}" "${DONE_TASKS[@]:$doneIndex}")
    fi
    rectifyTasks
    listTasks
  else
    echo "please specify task index, not name!"
  fi
}

# first argument is input string
fillWidthChars () {
  outString=$1
  repeat_count=$((($WINDOW_WIDTH-${#outString}-2)/2))
  for i in {1..$repeat_count}; do
    outString="$outString$REPEAT_CHAR"
  done
  echo $outString
}

# TODO: write help
help () {
  echo help meeeeee
}

initTasks () {
  TASKS=$(<$FILE_TASKS)
  TASKS_ARR=("${(f)TASKS}")

  NEW_TASKS=()
  DONE_TASKS=()
  PROG_TASK=""
  NEW_TASKS_DISPLAY=()
  DONE_TASKS_DISPLAY=()

  for task in $TASKS_ARR; do
    parsedTask=("${(@s/|/)task}")
    if [[ $task == *"|NEW"* ]]; then
      NEW_TASKS+="$parsedTask[1]"
    elif [[ $task == *"|DONE"* ]]; then
      DONE_TASKS+="$parsedTask[1]"
    fi
    if [[ $task == *"|PROG"* ]]; then
      PROG_TASK="$parsedTask[1]"
    fi
  done
  
  NEW_TASKS_COUNT=${#NEW_TASKS[@]}
  DONE_TASKS_COUNT=${#DONE_TASKS[@]}
  TOTAL_TASK_COUNT=$(($NEW_TASKS_COUNT+$DONE_TASKS_COUNT))
  
  count=0
  spaces="   "
  for task in $NEW_TASKS;
  do
    parsedTask=("${(@s/|/)task}")
    parsedTaskString=$parsedTask
    if [[ ${#parsedTaskString} -gt $((WINDOW_WIDTH-6)) ]]; then
      # add 8 spaces at every $WINDOW_WIDTH-6 chars
      repeats=$(( $#parsedTaskString / (WINDOW_WIDTH-6) ))
      for i in {1..$repeats}; do
        parsedTask[1]=${parsedTaskString:0:(i*WINDOW_WIDTH)-8}"        "${parsedTaskString:(i*WINDOW_WIDTH)-8:$#parsedTaskString}
        parsedTaskString=$parsedTask[1]
      done
    fi

    if [[ $count -ge 9 ]]; then
      spaces="  "
    fi

    if [[ $task == $PROG_TASK ]]; then
      NEW_TASKS_DISPLAY+="$spaces$((count+=1))  $PROG_SYMBOL  $parsedTask[1]"
    else
      NEW_TASKS_DISPLAY+="$spaces$((count+=1))  $TODO_SYMBOL  $parsedTask[1]"
    fi
  done

  for task in $DONE_TASKS;
  do
    parsedTask=("${(@s/|/)task}")
    parsedTaskString=$parsedTask
    if [[ ${#parsedTaskString} -gt $((WINDOW_WIDTH-6)) ]]; then
      # add 8 spaces at every $WINDOW_WIDTH-6 chars
      repeats=$(( $#parsedTaskString / (WINDOW_WIDTH-6) ))
      for i in {1..$repeats}; do
        parsedTask[1]=${parsedTaskString:0:(i*WINDOW_WIDTH)-8}"        "${parsedTaskString:(i*WINDOW_WIDTH)-8:$#parsedTaskString}
        parsedTaskString=$parsedTask[1]
      done
    fi

    if [[ $count -ge 9 ]]; then
      spaces="  "
    fi

    if [[ $task == $PROG_TASK ]]; then
      DONE_TASKS_DISPLAY+="$spaces$((count+=1))  $PROG_SYMBOL  $parsedTask[1]"
    else
      DONE_TASKS_DISPLAY+="$spaces$((count+=1))  $DONE_SYMBOL  $parsedTask[1]"
    fi
  done
}

listTasks () {
  clear
  initTasks
  echo ""
  fillWidthChars "  > todos"
  echo ""
  if [[ $TOTAL_TASK_COUNT -eq 0 ]]; then
    echo "   you don't have any todos!\n"
  fi
  for taskName in $NEW_TASKS_DISPLAY
  do
    echo $taskName
  done
  echo ""
  for taskName in $DONE_TASKS_DISPLAY
  do 
    echo $taskName
  done
  echo ""
}

# set task to in-progress
progTask () {
  lenNew=${#NEW_TASKS[@]}
  lenDone=${#DONE_TASKS[@]}

  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    if [[ $1 -le $lenNew ]]; then
      progTask=$NEW_TASKS[$1]
      NEW_TASKS=("${NEW_TASKS[@]:0:$1-1}" "${progTask}|PROG" "${NEW_TASKS[@]:$1}")
    elif [[ $1 -le (($lenDone+$lenNew)) ]]; then
      progTask=$DONE_TASKS[$(($1-$lenNew))]
      doneIndex=$(($1-$lenNew))
      DONE_TASKS=("${DONE_TASKS[@]:0:$doneIndex-1}" "${progTask}|PROG" "${DONE_TASKS[@]:$doneIndex}")
    fi
    PROG_TASK=$progTask
    rectifyTasks
    topTask "$1"
    listTasks
  else
    echo "please specify task index, not name!"
  fi
}

# set done task to new by index
undoTask () {
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    taskIndex=$(($1-$NEW_TASKS_COUNT))
    undoTask=$DONE_TASKS[$taskIndex]
    parsedTask=("${(@s/|/)undoTask}")
    NEW_TASKS+=$parsedTask[1]
    DONE_TASKS=("${DONE_TASKS[@]:0:$taskIndex-1}" "${DONE_TASKS[@]:$taskIndex}")
    
    rectifyTasks
    listTasks
  else
    echo "please specify task index, not name!"
  fi
}

# change task statuses in save file
rectifyTasks () {
  # clear file
  clearTaskFile
  
  # rebuild file with current new tasks
  for task in $NEW_TASKS;
  do
    if [[ $task == $PROG_TASK ]]; then
      echo -n $task"|NEW|PROG\n" >> $FILE_TASKS
    else
      echo -n $task"|NEW|\n" >> $FILE_TASKS
    fi
  done 
  
  # add done tasks to file
  for task in $DONE_TASKS;
  do
    parsedTask=("${(@s/|/)task}")
    if [[ $task == $PROG_TASK ]]; then
      echo -n $parsedTask[1]"|DONE|PROG\n" >> $FILE_TASKS
    else
      echo -n $parsedTask[1]"|DONE|\n" >> $FILE_TASKS
    fi
  done
}

resizeWindow () {
  printf "\e[8;51;64t"
  clear
  WINDOW_WIDTH=64
}

topTask () {
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    topTask=${NEW_TASKS[$1]}
    SORTED_TASKS=($topTask)

    for (( i=1; i <= ${#NEW_TASKS[@]}; i++ )); do
      if [[ $NEW_TASKS[$i] == $topTask ]]; then
        continue
      else
        SORTED_TASKS+="$NEW_TASKS[$i]"
      fi
    done

    NEW_TASKS=($SORTED_TASKS)
    
    rectifyTasks
    listTasks
  else
    echo "please specify task index, not name!"
  fi
}

