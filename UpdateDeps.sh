#!/bin/sh

echo " _   _           _       _      ______               "
echo "| | | |         | |     | |     |  _  \              "
echo "| | | |_ __   __| | __ _| |_ ___| | | |___ _ __  ___ "
echo "| | | | '_ \ / _\` |/ _\` | __/ _ \ | | / _ \ '_ \/ __|"
echo "| |_| | |_) | (_| | (_| | ||  __/ |/ /  __/ |_) \__ \\"
echo " \___/| .__/ \__,_|\__,_|\__\___|___/ \___| .__/|___/"
echo "      | |                                 | |        "
echo "      |_|                                 |_|        "
echo "                                                     "
echo "                                                     "

# --------------------------------------------------------------------------- #

function isUpdate() {
    if [ "$1" == "-U" ]; then
        echo "---Running script with maven update parameter---"
        UPDATE_PARAM="-U"
    fi
}

# --------------------------------------------------------------------------- #

function buildProject() {
    echo $LINE
    echo 'Building '$PROJECT' project'
    echo $LINE
    echo
    mvn clean install $UPDATE_PARAM
    echo
    echo $LINE
    echo
    echo
}

# --------------------------------------------------------------------------- #

function navigateIntoDir() {
    echo $LINE
    echo 'Navigating in '$PROJECT' project'
    echo $LINE
    cd $PROJECT
    echo $(pwd)
}

# --------------------------------------------------------------------------- #

function gitPulling() {
    echo $LINE
    echo 'Pulling latest '$PROJECT' project'
    echo $LINE
    CHANGES_MADE=$(git pull);
    # git pull
    echo $LINE
}

# --------------------------------------------------------------------------- #

function help() {
  echo "Usage: UpdateDeps.sh [OPTION]..."
  echo "Updates repos and builds all the projects in the current directory."
  echo
  echo "Options:"
  echo "  -f, --force   Force a rebuild of all projects"
  echo "  -U            Run Maven with the update parameter"
  echo "  -h, --help    Display this help message"
}

# --------------------------------------------------------------------------- #

cd /c/_Projects
LINE="=============================================="
PROJECT='DummyNameOfARepoFolder'
UPDATE_PARAM=''
CHANGES_MADE=''

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force)
      FORCE_BUILD=true
      ;;
    -U)
      isUpdate $1
      ;;
    -h|--help)
      help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help to see the available options."
      exit 1
      ;;
  esac
  shift
done

for OUTPUT in $(ls -d -- */); do
  PROJECT="$OUTPUT"
  navigateIntoDir
  gitPulling
  if [ "$CHANGES_MADE" != "Already up to date." ] || [ "$FORCE_BUILD" = true ]; then
    buildProject
  else
    echo "No building for '$OUTPUT', already up to date."
  fi
  cd ../
done