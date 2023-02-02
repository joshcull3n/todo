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

# init global vars
GLOBAL_DELIMITER="|"
DEFAULT_LIST=""
# SNOOZE_TIME=86400 # TODO
TASKS_COUNT=0
INCOMPLETE_COUNT=0
COMPLETE_COUNT=0

# TODO:
#  - specify list
#  - specify priority
addTask () {
  if [[ -z $1 ]]; then
    sendMessage "Task must not be empty."
    exit
  fi

  ID=""
  LIST=""
  NAME=""
  STATUS=""
  DATE_ADDED=$(date +"%s")
  DATE_UPDATED=$DATE_ADDED
  PRIORITY=""
  SNOOZE=""

  # Generate ID from last ID in task list
  if [[ -z $TASKS[1] ]]; then
    ID=1
  else
    ID=$(($TASKS_COUNT+1))
  fi
  # Get List
  LIST=$DEFAULT_LIST
  # Get Task Name
  NAME=$1
  # Status
  STATUS="INCOMPLETE"

  TASKS+=("$ID|$LIST|$NAME|$STATUS|$DATE_ADDED|$DATE_UPDATED|$PRIORITY|$SNOOZE")
}

# Empty list of tasks (specify --completed or --all)
# If clearing completed tasks, all incomplete tasks need their IDs adjusted
clearTasks () {
  if [[ ($1 == "--all") || ($1 == "-y") ]]; then
    clearTasksFile
  elif [[ $1 == "--done" ]]; then
    if [[ $COMPLETE_COUNT -eq 0 ]]; then
      sendMessage "you haven't completed any tasks yet, doofus."
      exit
    else
      count=1
      for task in $TASKS;
      do
        if [[ $task == *"|COMPLETE|"* ]]; then
          deleteTask $count
        else
          count=$(($count+1))
        fi
      done
      sendMessage "Completed tasks cleared."
      commitTasks
      exit
    fi
  else
    sendMessage "Please specify --done or --all."
    exit
  fi
}

clearTasksFile () {
  echo -n > $FILE_TASKS
  TASKS=""
}

changeTaskStatus () {
  if [[ $1 -gt $TASKS_COUNT ]]; then
    return
  fi
  task=$TASKS[$1]
  newStatus=$2
  taskDetails=("${(@s/|/)task}")
  TASKS[$1]=("$taskDetails[1]|$taskDetails[2]|$taskDetails[3]|$newStatus|$taskDetails[5]|$(date +"%s")|$taskDetails[7]|$taskDetails[8]")
}

checkArgumentIsInt () {
  if [[ $1 =~ ^-?[0-9]+$ ]]; then
    return 0
  else
    sendMessage "Please specify task number."
    exit
  fi
}

commitTasks () {
  echo -n > $FILE_TASKS

  for task in $TASKS;
  do
    echo $task >> $FILE_TASKS
  done
}

completeTask () {
  checkArgumentIsInt $1
  changeTaskStatus $1 "COMPLETE"
}

# Delete task by ID
deleteTask () {
  checkArgumentIsInt $1
  TASKS=("${TASKS[@]:0:$1-1}" "${TASKS[@]:$1}")
}

# TODO: Read more details about task - timestamp, description, priority, etc.
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
  DISPLAY_TASKS=()

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
      DISPLAY_TASKS+="$spaces$((count+=1)) · $taskDetails[3]"
    elif [[ $taskDetails[4] == "COMPLETE" ]]; then
      DISPLAY_TASKS+="$spaces$((count+=1)) x $taskDetails[3]"
    elif [[ $taskDetails[4] == "IN-PROGRESS" ]]; then
      DISPLAY_TASKS+="$spaces$((count+=1)) > \e[3m$taskDetails[3]\e[0m"
    fi
  done
}

listTasks () {
  formatTasks

  echo ""
  fillWidthChars "  > todos"
  echo ""
  if [[ ${#DISPLAY_TASKS[@]} -eq 0 ]]; then
    echo "    you don't have any todos...\n"
  fi
  for taskName in $DISPLAY_TASKS;
  do
    echo $taskName
  done
  echo ""
}

moveTaskTop () {
  checkArgumentIsInt $1
  topTask=$TASKS[$1]
  tasksSorted=($topTask)

  for task in $TASKS; do
    if [[ $task == $topTask ]]; then
      continue
    else
      tasksSorted+=$task
    fi
  done
  TASKS=($tasksSorted)
}

moveTaskBottom () {
  checkArgumentIsInt $1
  bottomTask=$TASKS[$1]
  tasksSorted=()
  for task in $TASKS; do
    if [[ $task == $bottomTask ]]; then
      continue
    else
      tasksSorted+=$task
    fi
  done
  tasksSorted+=$bottomTask
  TASKS=($tasksSorted)
}

progTask () {
  checkArgumentIsInt $1
  count=1
  for task in $TASKS;
  do
    if [[ $task == *"|IN-PROGRESS|"* ]]; then
      changeTaskStatus $count "INCOMPLETE"
    fi
    count=$(($count+1))
  done
      
  changeTaskStatus $1 "IN-PROGRESS"
}

# Parse tasks from tasks.txt file into array
# TODO: Check if snoozed tasks should be reset based on SNOOZE_TIME
readTasks () {
  TASKS_RAW=$(<$FILE_TASKS)
  TASKS=("${(f)TASKS_RAW}")
  TASKS_COUNT=${#TASKS[@]} # if list is empty, this count will still be 1

  for task in $TASKS
  do
    if [[ $task == *"|INCOMPLETE|"* ]]; then
      INCOMPLETE_COUNT=$(($INCOMPLETE_COUNT+1))
    elif [[ $task == *"|COMPLETE|"* ]]; then
      COMPLETE_COUNT=$(($COMPLETE_COUNT+1))
    fi
  done
}

resizeWindow () {
  printf "\e[8;35;64t"
  WINDOW_WIDTH=64
}

# Max argument length is 57 chars
sendMessage() {
  args=($@)
  listTasks

  # calculate padding for longest message
  padding=""
  lenMessage=0
  right_justify=0

  for arg in $args; do
    if [[ ${#arg} -le 57 ]]; then
      if [[ $lenMessage -le ${#arg} ]]; then
        lenMessage=${#arg}
        right_justify=$(($WINDOW_WIDTH - $lenMessage - 6))
      fi
    else
      echo "INTERNAL ERROR: message too long"
      exit
    fi
  done

  for i in {1..$right_justify}; do
      padding="$padding "
    done

  for arg in $args; do
    echo "$padding > $arg"
  done
}

snoozeTask () {

}

undoTask () {
  checkArgumentIsInt $1
  changeTaskStatus $1 "INCOMPLETE"
}

unrecognized () {
  sendMessage "Unrecognized command. Usage:" "  td {list|add|done|delete|...} {flags|task}" "  See help for more."
  exit
}
