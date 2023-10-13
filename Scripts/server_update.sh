#! /bin/sh

SSH_KEY_PATH=/home/github_key/AkoMarket
PROJ_USER=TomcatRuntime:AkoMarket_Admin
PROJ_PATH=/usr/local/Server_Repo


function ch_owner()
{
  echo ""
  echo "Now changing ownership of the project foler.."
  sudo chown -R $PROJ_USER $PROJ_PATH && sudo chmod -R 770 $PROJ_PATH
  echo "Successfully changed ownership of the project path"
  sudo chcon -R -t bin_t $PROJ_PATH
  echo "Successfully changed file type of the project path to bin_t"
}

function try_pull()
{
  git pull origin $1
  if [ $? -eq 0 ]; then
    echo "Successfully pulled from $1"
  else
    echo ""
    echo "Failed to pull from $1"
    ch_owner
    exit -1
  fi
}

function try_checkout()
{
  git checkout $1
  if [ $? -eq 0 ]; then
    echo "Successfully checkouted from $1"
  else
    echo ""
    echo "Failed to checkout to $1"
    ch_owner
    exit -2
  fi
}

function print_help()
{
  echo ""
  echo "Usage: server_update.sh [--option] arguments"
  echo "    -b --branch  : git pull from branch"
  echo "    -h --hash    : git checkout to hash"
  echo ""
}


if [ $# -eq 1 ]; then
  print_help
  exit 0
fi

eval $(ssh-agent -s) && ssh-add $SSH_KEY_PATH
if [ $? != 0 ]; then
  echo ""
  echo "Failed to add ssh key, exiting from the program.."
  exit -3
fi

cd $PROJ_PATH

if [ $# -eq 0 ]; then
  git reset --hard
  try_pull main
  ch_owner
  exit 0
fi

case $1 in
  -b|--branch)
    shift
    branches=()
    git reset --hard
    while [[ $# -gt 0 ]]; do
      try_pull $1
      branches+=($1)
      shift
    done
    echo ""
    echo "Successfully pulled from ${branches[@]}"
    ;;
  -h|--hash)
    git reset --hard
    try_hash $2
    echo ""
    echo "Successfully checkouted to $2"
    ;;
  *)
    echo ""
    echo "Invalid option"
    print_help
    exit 0
    ;;
esac

ch_owner

