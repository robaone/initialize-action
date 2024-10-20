# initialize-action

https://youtu.be/I2zRjv3GWlc

## Description

The **Initialize Action** sets up the environment for your workflow, cancels previous runs, and generates a project matrix for subsequent jobs. This action is designed to streamline your CI/CD pipeline by managing previous workflow executions and creating a dynamic project matrix based on changed files.

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `project-root` | Project root folder | No | `.` |
| `script-version` | Version of the script to use | No | `0.5.1` |

## Outputs

| Output | Description |
|--------|-------------|
| `matrix` | The project matrix for subsequent jobs |
| `files` | List of changed files |

## Usage

```
name: CI Workflow

on:
  push:
    branches:
      - main
      - develop

jobs:
  initialize:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      
      - name: Initialize Action
        uses: robaone/initialize-action@v0.6.0
        with:
          project-root: 'your/project/root'
      
      # Additional steps to use the outputs can go here
```

## Steps

Steps
1. **Cancel Previous Runs**: This step cancels any previous runs if the current branch is not `develop` or `main`.
1. **Download Scripts**: The action downloads the specified version of the necessary scripts.
1. **Unzip Scripts**: This step extracts the downloaded scripts from the zip file.
1. **List Modified Files**: Uses the `tj-actions/changed-files` action to gather all modified files and processes them.
1. **Set Dynamic Matrix**: This step generates a project matrix based on the modified files and outputs it for use in subsequent jobs.

## Example

Here's an example of how you can utilize the outputs of the Initialize Action in your workflow:

```
name: Continuous Integration & Delivery

on:
  push:
    branches:
    - main
  pull_request:
    branches:
    - main

jobs:
  initialize:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - name: initialize
        id: initialize
        uses: robaone/initialize-action@v0.6.0
        with:
          project-root: .
    outputs:
      matrix: ${{ steps.initialize.outputs.matrix }}
  unit-tests:
    needs: [initialize]
    strategy:
      matrix: ${{ fromJson(needs.initialize.outputs.matrix) }}
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
```

## Inter Project dependencies

This GitHub Action uses a custom dependency management system based on .depends files. The system is designed to identify which projects are affected by changes to specific files in your repository.

### How It Works

1. The action searches for `.depends` files in your repository.
1. Each `.depends` file should be located in a project directory and contain a list of file paths or patterns that the project depends on.
1. When files are changed in a pull request or push, the action checks if any of these files match the patterns in the `.depends` files.
1. If a match is found, the corresponding project is identified as affected by the change.

### .depends File Format

Each line in a `.depends` file should contain a file path or pattern relative to the repository root. You can use wildcards (`*`) in these patterns.

Example `.depends` file:

```
src/shared/*.js
config/database.yml
*.gemspec
```

### Usage

Usage

1. Create a `.depends` file in each project directory that you want to track dependencies for.
1. List the files or patterns that the project depends on in the `.depends` file.
1. When you run this action, it will output the names of projects affected by the changes in your commit or pull request.
