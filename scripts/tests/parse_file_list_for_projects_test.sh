#!/bin/bash

# This script tests the parse_file_list_for_projects.sh script

CMD=$1

if [ "$CMD" == "" ]; then
  echo "You must provide a command to run"
  exit 1
fi

function assert_equals {
  if [ "$1" != "$2" ]; then
    echo "Expected: $1"
    echo "Actual:   $2"
    exit 1
  else
    echo "OK"
  fi
}

function beforeAll {
    export FOLDER_EXISTS_CMD=$SCRIPT_DIR/mock_cmd.sh
    export BUILD_DEPENDS_PATH=$SCRIPT_DIR/mock_cmd.sh
    export GIT_CMD=$SCRIPT_DIR/mock_cmd.sh
    export PROJECT_ROOT=projects
}

function beforeEach {
    export MOCK_ARGUMENT_FILE="$(mktemp)"
    export MOCK_TRACKING_FILE="$(mktemp)"
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

beforeAll

echo Scenario: No Files
beforeEach

# GIVEN

INPUT=""
EXPECTED_RESULT=""

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"

echo Scenario: Project files
beforeEach

# GIVEN

INPUT=".github/workflows/git-flow.yml
projects/GithubWebhook/README.md
projects/GithubWebhook/src/index.ts
projects/Other/README.md
docs/adr/0001-architecture-decision-record.md
README.md"
EXPECTED_RESULT="GithubWebhook
Other"
export MOCK_RESPONSES='[
  {"name":"repository root","stdout":"/home/git/repo"},
  {"name":"project root folder exists","stdout":"1"},
  {"name":"dependency folders"},
  {"name":"folder 1 exists"},
  {"name":"folder 2 exists"}
]'

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"

echo Scenario: Project files with dependencies
beforeEach

# GIVEN

INPUT=".github/workflows/git-flow.yml
projects/GithubWebhook/README.md
projects/GithubWebhook/src/index.ts
projects/Other/README.md
docs/adr/0001-architecture-decision-record.md
README.md"
EXPECTED_RESULT="GithubWebhook
Other
project-with-dependency"
export MOCK_RESPONSES='[
  {"name":"repository root","stdout":"/home/git/repo"},
  {"name":"project root folder exists"},
  {"name":"dependency folders","stdout":"project-with-dependency"},
  {"name":"folder 1 exists"},
  {"name":"folder 2 exists"},
  {"name":"folder 3 exists"}
]'

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"

echo Scenario: Project files with dependencies where project root is .
beforeEach

# GIVEN

export PROJECT_ROOT="."
INPUT=".github/workflows/git-flow.yml
GithubWebhook/README.md
GithubWebhook/src/index.ts
Other/README.md
docs/adr/0001-architecture-decision-record.md
README.md"
EXPECTED_RESULT="GithubWebhook
Other
docs
project-with-dependency"
export MOCK_RESPONSES='[
  {"name":"repository root","stdout":"/home/git/repo"},
  {"name":"folder 1 exists"},
  {"name":"folder 2 exists"},
  {"name":"folder 3 exists"},
  {"name":"README.md is not a folder","stdout":"0"},
  {"name":"folder 4 exists"},
  {"name":"dependency folders","stdout":"project-with-dependency"},
  {"name":"folder 1 exists"},
  {"name":"folder 2 exists"},
  {"name":"folder 3 exists"},
  {"name":"folder 4 exists"},
  {"name":"folder 5 exists"}
]'

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"

echo Scenario: Pattern project root with multiple directories
beforeEach

# GIVEN

export PROJECT_ROOT="(services|tools)"
INPUT=".github/workflows/git-flow.yml
services/tango/main.go
services/tango/pkg/sub/file.go
services/README.md
tools/sugarcane/pom.xml
docs/adr/0001-architecture-decision-record.md
README.md"
EXPECTED_RESULT="services/packrat
services/tango
tools/sugarcane"
export MOCK_RESPONSES='[
  {"name":"repository root","stdout":"/home/git/repo"},
  {"name":"dependency folders","stdout":"services/packrat"},
  {"name":"services/README.md is not a folder","stdout":"0"},
  {"name":"services/packrat exists"},
  {"name":"services/tango exists"},
  {"name":"tools/sugarcane exists"}
]'

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"

echo Scenario: Pattern project root without parentheses
beforeEach

# GIVEN

export PROJECT_ROOT="services|tools"
INPUT="services/tango/main.go
tools/sugarcane/pom.xml"
EXPECTED_RESULT="services/tango
tools/sugarcane"
export MOCK_RESPONSES='[
  {"name":"repository root","stdout":"/home/git/repo"},
  {"name":"dependency folders"},
  {"name":"services/tango exists"},
  {"name":"tools/sugarcane exists"}
]'

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"

echo Scenario: Pattern project root with no matching projects
beforeEach

# GIVEN

export PROJECT_ROOT="(services|tools)"
INPUT=".github/workflows/git-flow.yml
docs/adr/0001-architecture-decision-record.md
README.md"
EXPECTED_RESULT=""
export MOCK_RESPONSES='[
  {"name":"repository root","stdout":"/home/git/repo"},
  {"name":"dependency folders"}
]'

# WHEN

ACTUAL_RESULT="$(echo "$INPUT" | $CMD)"

# THEN

assert_equals "0" "$?"
assert_equals "$EXPECTED_RESULT" "$ACTUAL_RESULT"
