#!/bin/bash
set -eo pipefail

# VARIABLES
SCRIPT_FOLDER="./scripts"
SSO_SECURITY="off"
DOCKER_RUN_REFERENCE='-d'
REPOS="ms-customer"
MODE="embed"

# COMMAND LIST
INIT="init"
RUN="run"
STOP="stop"
AWS="aws"

### Source all files in scripts folder except cli.sh ###
for src in $(ls -1 $SCRIPT_FOLDER/*.sh | grep -v cli.sh); do
  source $src
done

function banner(){
  printf "   ___  _____   __  __________  ____  __   ____ \n"
  printf "  / _ \/ __/ | / / /_  __/ __ \/ __ \/ /  / __/ \n"
  printf " / // / _/ | |/ /   / / / /_/ / /_/ / /___\ \   \n"
  printf "/____/___/ |___/   /_/  \____/\____/____/___/   \n"
}

function dumpVariables(){
  stripe_
  printf "Trace variables:\n"
  printf "PARENT_BRANCH: [$PARENT_BRANCH]\n"
  printf "BASE_PATH: [$BASE_PATH]\n"
  printf "CODE_FOLDER:[$CODE_FOLDER]\n"
  printf "SCRIPT_FOLDER: [$SCRIPT_FOLDER]\n"
  printf "M2_LOCATION: [$M2_LOCATION]\n"
}

function usage() {
  banner
  echo "Usage: cli -a APPLICATION[,APPLICATION][,..] [ -m ] [ -b ] [ -r ] [ -f ]"
  echo "Applications (in recommended order):"
  printf "    %-14s-- prepares your environment\n" $INIT
  printf "    %-14s-- allows you to stop the stack or its part if it is previously started by run.sh script.\n" $STOP
  printf "    %-14s-- allows you to run the stack or its part in the specified running mode\n" $RUN
  printf "    %-14s-- Runs the AWS mock (localstack) \n" $AWS
  stripe_
  printf "Options:\n"
  printf "      -a APPLICATION %-2s-- Comma-delimited list from above in the order of execution\n"
  printf "      -e %-14s-- Embeded - This mode assumes that everything is running in a single JVM with mocked 3rd party services (like Kafka, Zookeeper, database, etc) \n"
  printf "      -r %-14s-- repositories\n"
  dumpVariables
  exit
}

help_extra() {
  echo "Examples:"
  echo
  echo "cli -a run                   # allows you to run the stack or its part in the specified running mode."
  echo "cli -a run,stop              # allows you to run and stop the stack or its part in the specified running mode."
  exit
}

func_exists() {
  case $1 in
    $RUN|$STOP|$INIT|$AWS)
        return 0
        ;;
    *)
      echo "*** Invalid application: $1 ***"
      echo "" && usage
  esac
  return 1
}

### *** ENTRY *** ###
[[ -z "$@" ]] && usage

### Process command ###
while getopts "oedha:r:" opt; do
  case $opt in
    a)  IFS=',' read -a APPS <<< $OPTARG    # ${OPTARG,,} converts $OPTARG to all lowercase letters
        ;;
    r)  REPOS=$OPTARG
        ;;		
    o)  SSO_SECURITY='on'
        ;;		
    e)  MODE='embed'
        ;;
    d)  MODE='docker'
        ;;
    h)  MODE='hybrid'
        ;;
    *)  usage
        ;;
  esac
done

### If no apps specified, exit ###
[[ -n "$APPS" ]] || usage

### Confirm status of docker network "devnet"
if ! docker network inspect devnet >/dev/null 2>&1; then
  echo "** Creating docker network \"devnet\""
  docker network create devnet
fi

for app in ${APPS[@]}; do
    start=$SECONDS
    func_exists $app before && { echo "===== Initialization: $app ====="; eval $app"_init"; }
    func_exists $app exec && { echo "===== Execution: $app ====="; eval $app"_exec"; }
    func_exists $app after && { echo "===== Cleanup: $app ====="; eval $app"_clean" $3; }
    duration=$(( SECONDS - start ))
    echo "Execution time: $duration seconds"
done
