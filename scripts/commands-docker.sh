container_exists() {
  [[ -n "$VERBOSE" ]] && echo Searching for container with name: $1
  FOUND=$(docker ps -a -q --filter name=^/$1$)  # filter name=$1 is a substring match; ^/$1$ is exact match
  if [ -n "$FOUND" ]; then
    [[ -n "$2" ]] && eval "$2=$FOUND"
    [[ -n "$VERBOSE" ]] && echo Found container named $1 || return 0
  else
    [[ -n "$VERBOSE" ]] && echo Found no containers named $1 || return 1
  fi
}

image_exists() {
  [[ -n "$VERBOSE" ]] && echo Searching for images of $1
  FOUND=$(docker images -a -q $1)
  if [ -n "$FOUND" ]; then
    [[ -n "$VERBOSE" ]] && echo Found image $1 || return 0
  else
    [[ -n "$VERBOSE" ]] && echo Found no images $1 || return 1
  fi
}

container_running() {
  [[ -n "$VERBOSE" ]] && echo Searching for running container with name: $1
  FOUND=$(docker ps -q --filter name=^/$1$)  # filter name=$1 is a substring match; ^/$1$ is exact match
  if [ -n "$FOUND" ]; then
    [[ -n "$2" ]] && eval "$2=$FOUND"
    [[ -n "$VERBOSE" ]] && echo Found container named $1 || return 0
  else
    [[ -n "$VERBOSE" ]] && echo Found no containers named $1 || return 1
  fi
}

clone_container() {
  CLONING=$1
  container_check_and_remove $2
  echo Cloning container ID: $CLONING...
  docker commit $CLONING $2
  docker run -d --name $2 $2 || exit $?
}

container_check_and_remove() {
  if container_exists $1; then
    echo "** Docker removing existing $1 container **"
    docker rm -f $1
  fi
}

image_check_and_remove() {
  if image_exists $1; then
    echo "** Docker removing existing $1 image **"
    docker rmi -f $1
  fi
}

check_exists() {
  if [ -z "$1" ]; then
    echo Please provide an argument for $2.
    echo Exiting
    exit 1
  fi
}

check_directory() {
  if [ ! -d "$1" ]; then
    echo No directory at: $1
    echo Exiting
    exit 1
  fi
}

check_and_make_directory() {
  if [ ! -d "$1" ]; then
    echo No directory at: $1
    echo Creating one..
  else
    echo Directory found at: $1
    echo Deleting directory...
    rm -rf $1
  fi
  mkdir -p $1
}

check_file() {
  if [ ! -f "$1" ]; then
    echo No File at: $1
    echo Exiting
    exit 1
  fi
}