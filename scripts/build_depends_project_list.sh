#!/bin/bash

FILES="$(cat)"

SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [ "$FIND_PATH" == "" ]; then
  FIND_PATH="$(which find)"
fi

if [ "$CAT_PATH" == "" ]; then
  CAT_PATH="$(which cat)"
fi

# Get the list of projects

function list_projects_with_depends_file() {
  PROJECTS_FOLDER="$SCRIPT_DIR/../$PROJECT_ROOT"
  for f in $($FIND_PATH $PROJECTS_FOLDER -name .depends)
  do
    echo $(basename $(dirname $f))
  done
}

# For each project, check if the file is in the .depends file
for project in $(list_projects_with_depends_file)
do
  for file in $FILES
  do
    for depends_path in $($CAT_PATH "$SCRIPT_DIR/../$PROJECT_ROOT/$project/.depends")
    do
      DEPENDS_PATH_PATTERN=$(echo $depends_path | sed 's/\./\\./g' | sed 's/\*/.*/g')
      if [[ $file =~ $DEPENDS_PATH_PATTERN ]]; then
        echo $project
        break
      fi
    done
  done
done