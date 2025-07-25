#!/bin/bash

################################################################################
# Script: INP Environment Setup
#
# Description: This script sets up a development environment for the
# INP project
#
# WARNING: This script only works with Ghostty and MacOS since it relies
# on AppleScript to control the terminal.
#
# Version:  1.1.0
################################################################################

# Configuration variables
TERMINAL_APP="Ghostty"
BACKEND_PROJECT_PATH="$HOME/DevProjects/itcs-inp-b"
FRONTEND_PROJECT_PATH="$HOME/DevProjects/itcs-inp-f"
VENV_PATH="venv/bin/activate"
EDITOR_CMD="nvim ."
BACKEND_RUN_CMD="rpy"
FRONTEND_RUN_CMD="npm start"
EDITOR_QUIT_KEY="q"

validate_environment() {
    echo "Validating environment..."

    if [ ! -d "$BACKEND_PROJECT_PATH" ]; then
        echo "Error: Backend project directory not found: $BACKEND_PROJECT_PATH"
        exit 1
    fi

    if [ ! -d "$FRONTEND_PROJECT_PATH" ]; then
        echo "Error: Frontend project directory not found: $FRONTEND_PROJECT_PATH"
        exit 1
    fi

    if [ ! -f "$BACKEND_PROJECT_PATH/$VENV_PATH" ]; then
        echo "Error: Virtual environment not found: $BACKEND_PROJECT_PATH/$VENV_PATH"
        exit 1
    fi

    if [ ! -f "$FRONTEND_PROJECT_PATH/package.json" ]; then
        echo "Error: Frontend package.json not found in: $FRONTEND_PROJECT_PATH"
        exit 1
    fi

    echo "Environment validation passed."
}

create_new_tab() {
    osascript -e "
    tell application \"$TERMINAL_APP\"
        activate
        tell application \"System Events\"
            keystroke \"t\" using {command down}
        end tell
    end tell
    "
}

execute_in_tab() {
    local tab_number="$1"
    local project_path="$2"
    local commands="$3"

    osascript -e "
    tell application \"$TERMINAL_APP\"
        activate
        tell application \"System Events\"
            keystroke \"$tab_number\" using {command down}
        end tell
        tell application \"System Events\"
            keystroke \"cd $project_path\" & return
            $commands
        end tell
    end tell
    "
}

validate_environment

create_new_tab
create_new_tab
create_new_tab

# Setup first tab: Backend with editor
execute_in_tab "1" "$BACKEND_PROJECT_PATH" "
    keystroke \"source $VENV_PATH\" & return
    keystroke \"$EDITOR_CMD\" & return
    keystroke \"$EDITOR_QUIT_KEY\" using {option down}
"

# Setup second tab: Backend with development server
execute_in_tab "2" "$BACKEND_PROJECT_PATH" "
    keystroke \"source $VENV_PATH\" & return
    keystroke \"$BACKEND_RUN_CMD\" & return
"

# Setup third tab: Frontend with editor
execute_in_tab "3" "$FRONTEND_PROJECT_PATH" "
    keystroke \"$EDITOR_CMD\" & return
    keystroke \"$EDITOR_QUIT_KEY\" using {option down}
"

# Setup fourth tab: Frontend with development server
execute_in_tab "4" "$FRONTEND_PROJECT_PATH" "
    keystroke \"$FRONTEND_RUN_CMD\" & return
"

exit 0
