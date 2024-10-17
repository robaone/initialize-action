# initialize-action

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
        uses: your-username/initialize-action@v0.1
        with:
          project-root: 'your/project/root'
          script-version: '0.5.1'
      
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
        uses: robaone/initialize-action@v0.3.7
        with:
          project-root: .
          script-version: 0.5.1
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

