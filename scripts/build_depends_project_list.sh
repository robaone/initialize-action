#!/bin/bash

export LC_ALL=C

FILES="$(cat)"

SCRIPT_DIR=$(cd $(dirname $0); pwd)

if [ "$FIND_PATH" == "" ]; then
  FIND_PATH="$(which find)"
fi

if [ "$CAT_PATH" == "" ]; then
  CAT_PATH="$(which cat)"
fi

if [ "$GIT_CMD" == "" ]; then
  GIT_CMD="$(which git)"
fi

function git_root() {
  $GIT_CMD rev-parse --show-toplevel
}

function is_pattern() {
  local val="$1"
  local regex_meta='[][()|*+?{}]'
  if [[ "$val" =~ $regex_meta ]]; then
    return 0
  fi
  return 1
}

IS_PATTERN=false
if is_pattern "$PROJECT_ROOT"; then
  IS_PATTERN=true
fi

if [ "$IS_PATTERN" == "true" ]; then
  repo_root="$(git_root)"
  PROJECTS_FOLDER="$repo_root"
  for f in $($FIND_PATH "$PROJECTS_FOLDER" -name .depends)
  do
    rel_path="${f#"$repo_root"/}"
    rel_dir="$(dirname "$rel_path")"
    if [[ "$rel_dir" =~ ^($PROJECT_ROOT)/[^/]+$ ]]; then
      project="$rel_dir"
      if [ -f "$f" ]; then
        DEPENDS_FILE_PATH="$f"
      else
        DEPENDS_FILE_PATH="$repo_root/$rel_dir/.depends"
      fi
      matched=false
      for file in $FILES
      do
        if [ "$matched" == "true" ]; then
          break
        fi
        for depends_path in $($CAT_PATH "$DEPENDS_FILE_PATH")
        do
          DEPENDS_PATH_PATTERN=$(echo "$depends_path" | sed 's/\./\\./g' | sed 's/\*/.*/g')
          if [[ "$file" =~ ^$DEPENDS_PATH_PATTERN ]]; then
            echo "$project"
            matched=true
            break
          fi
        done
      done
    fi
  done
else
  function list_projects_with_depends_file() {
    if [ "$PROJECT_ROOT" == "" ] || [ "$PROJECT_ROOT" == "." ]; then
      PROJECTS_FOLDER="$(git_root)"
    else
      PROJECTS_FOLDER="$(git_root)/$PROJECT_ROOT"
    fi
    for f in $($FIND_PATH "$PROJECTS_FOLDER" -name .depends)
    do
      echo $(basename $(dirname "$f"))
    done
  }

  # For each project, check if the file is in the .depends file
  for project in $(list_projects_with_depends_file)
  do
    for file in $FILES
    do
      if [ "$PROJECT_ROOT" == "" ] || [ "$PROJECT_ROOT" == "." ]; then
        DEPENDS_FILE_PATH="$(git_root)/$project/.depends"
      else
        DEPENDS_FILE_PATH="$(git_root)/$PROJECT_ROOT/$project/.depends"
      fi
      for depends_path in $($CAT_PATH "$DEPENDS_FILE_PATH")
      do
        DEPENDS_PATH_PATTERN=$(echo "$depends_path" | sed 's/\./\\./g' | sed 's/\*/.*/g')
        if [[ "$file" =~ ^$DEPENDS_PATH_PATTERN ]]; then
          echo "$project"
          break
        fi
      done
    done
  done
fi
