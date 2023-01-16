### v2 ARCHITECTURE
# gather tasks from file at every run and add/update tasks object before rectifying at end of script.
#  - New structure is: ID, List, Name, Status, Date Added, Date Updated, Priority
#  - ID: int, 6 digit incrementing ID (i.e. 002589), required
#  - List: string, name of list (i.e. 'work tasks'), required
#  - Name: string, name/description of task (i.e. 'watch seinfeld' ), required
#  - Status: string, task status (i.e. INCOMPLETE, COMPLETE, SNOOZED, DELETED, DISMISSED, INPROGRESS), required
#  - Date Added: int, date task was created in epoch time, required
#  - Date Updated: int, date task was last edited in epoch time, required
#  - Priority: string, priority of task (i.e. LOW, MED, HIGH), not required
#  - Snooze Time: int, date task was snoozed in epoch time, not required
#
# script will begin with readTasks to collect initial state, and end with commitTasks to update file with any changes.


GLOBAL_DELIMITER="|"
DEFAULT_LIST=""
SNOOZE_TIME=86400 # one day

# TODO:
#  - specify list
#  - specify priority
addTask () {
  ID=""
  LIST=""
  NAME=""
  STATUS=""
  DATE_ADDED=$(date +"%s")
  DATE_UPDATED=$DATE_ADDED
  PRIORITY=""
  SNOOZE=""

  # Generate ID from last ID in task list
  lastItem=$TASKS[-1]
  if [[ -z lastItem ]]; then
    ID=0
  else
    lastID=$( echo $lastItem | cut -s -d "|" -f 1 )
    ID=$(( $lastID + 1 ))
  fi
  # Get List
  LIST=$DEFAULT_LIST
  # Get Task Name
  NAME=$1
  # Status
  STATUS="INCOMPLETE"

  TASKS+=("$ID|$LIST|$NAME|$STATUS|$DATE_ADDED|$DATE_UPDATED|$PRIORITY|$SNOOZE")
}

commitTasks () {
  echo -n > $FILE_TASKS

  for task in $TASKS;
  do
    echo $task >> $FILE_TASKS
  done
}

completeTask () {
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    task=$TASKS[$1]
    taskDetails=("${(@s/|/)task}")
    TASKS[$1]=("$taskDetails[1]|$taskDetails[2]|$taskDetails[3]|COMPLETE|$taskDetails[5]|$(date +"%s")|$taskDetails[7]|$taskDetails[8]")
  else
    echo "please specify task ID, not name!"
  fi
}

deleteTask () {

}

getTask () {

}

# fill the width of the window with specified char
fillWidthChars () {
  outString=$1
  repeat_count=$((($WINDOW_WIDTH-${#outString}-2)/2))
  for i in {1..$repeat_count}; do
    outString="$outString$REPEAT_CHAR"
  done
  echo $outString
}

# format all tasks into displayable format
formatTasks () {
  INCOMPLETE_TASKS=()
  COMPLETE_TASKS=()

  count=0
  spaces="   "
  for task in $TASKS;
  do
    taskDetails=("${(@s/|/)task}")
    taskDetailsString=$taskDetails
    if [[ ${#taskDetailsString} -gt $((WINDOW_WIDTH-6)) ]]; then
      repeats=$(( $#taskDetailsString / (WINDOW_WIDTH-6) ))
      for i in {1..$repeats}; do
        taskDetails[1]=${taskDetailsString:0:(i*WINDOW_WIDTH)-8}"        "${taskDetailsString:(i*WINDOW_WIDTH)-8:$#taskDetailsString}
        taskDetailsString=$taskDetails[1]
      done
    fi

    if [[ $count -ge 9 ]]; then
      spaces="  "
    fi

    if [[ $taskDetails[4] == "INCOMPLETE" ]]; then
      INCOMPLETE_TASKS+="$spaces$((count+=1))  $TODO_SYMBOL  $taskDetails[3]"
    elif [[ $taskDetails[4] == "COMPLETE" ]]; then
      COMPLETE_TASKS+="$spaces$((count+=1))  $DONE_SYMBOL  $taskDetails[3]"
    fi
  done
}

listTasks () {
  clear
  formatTasks

  echo ""
  fillWidthChars "  > todos"
  echo ""
  if [[ $TASKS_COUNT -eq 0 ]]; then
    echo "   you don't have any todos!\n"
  fi
  for taskName in $INCOMPLETE_TASKS
  do
    echo $taskName
  done
  echo ""
  for taskName in $COMPLETE_TASKS
  do 
    echo $taskName
  done
  echo ""
}

# TODO: Check if snoozed tasks should be reset based on SNOOZE_TIME
readTasks () {
  TASKS_RAW=$(<$FILE_TASKS)
  TASKS=("${(f)TASKS_RAW}")
  TASKS_COUNT=${#TASKS[@]}
}

snoozeTask () {

}