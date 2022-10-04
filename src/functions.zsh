# functions #

addTask () {
  # add task to new tasks array
  NEW_TASKS+=$1
  rectifyTasks
  listTasks
}

# takes number as input
completeTask () {
  doneTask=$NEW_TASKS[$1]
  DONE_TASKS+=$doneTask 
  NEW_TASKS=("${NEW_TASKS[@]:0:$1-1}" "${NEW_TASKS[@]:$1}") # remove from new task array
  rectifyTasks
  listTasks
}

# change task statuses in save file
rectifyTasks () {
  # clear file
  clearTaskFile
  
  # rebuild file with current new tasks
  for task in $NEW_TASKS;
  do
    echo -n $task"|NEW|\n" >> $FILE_TASKS
  done 
  
  # add done tasks to file
  for task in $DONE_TASKS;
  do
    echo -n $task"|DONE|\n" >> $FILE_TASKS
  done
}

clearTaskFile () {
  #clear
  truncate -s 0 $FILE_TASKS
}

listTasks () {
  #clear
  initTasks
  fillWidthChars " > todos"
  if [[ $TOTAL_TASKS -eq 1 ]]; then
    echo "\n   you don't have any todos!\n"
  fi
  for taskName in $NEW_TASKS_DISPLAY
  do
    echo " "$taskName
  done
  #fillWidthChars " > dones"
  for taskName in $DONE_TASKS_DISPLAY
  do 
    echo " "$taskName
  done
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
  listTasks
}

initTasks () {
  TASKS=$(<$FILE_TASKS)
  TASKS_ARR=("${(f)TASKS}")
  WINDOW_WIDTH=$(tput cols)
  WINDOW_HEIGHT=$(tput lines)

  NEW_TASKS=()
  NEW_TASKS_COUNT=0
  DONE_TASKS=()
  DONE_TASKS_COUNT=0
  NEW_TASKS_DISPLAY=()
  DONE_TASKS_DISPLAY=()

  for task in $TASKS_ARR; do
    parsedTask=("${(@s/|/)task}")
    if [[ $task == *"|NEW"* ]]; then
      NEW_TASKS+="$parsedTask[1]"
    elif [[ $task == *"|DONE"* ]]; then
      DONE_TASKS+="$parsedTask[1]"
    fi
  done
  
  NEW_TASKS_COUNT=${#NEW_TASKS[@]}
  DONE_TASKS_COUNT=${#DONE_TASKS[@]}

  count=0
  for task in $NEW_TASKS;
  do
    parsedTask=("${(@s/|/)task}")
    NEW_TASKS_DISPLAY+="$((count+=1))  $TODO_SYMBOL $parsedTask[1]"
  done

  for task in $DONE_TASKS;
  do
    parsedTask=("${(@s/|/)task}")
    DONE_TASKS_DISPLAY+="$((count+=1))  $DONE_SYMVOL $parsedTask[1]"
  done
}

help () {
  echo help meeeeee
}