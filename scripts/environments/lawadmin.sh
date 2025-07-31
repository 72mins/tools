#!/bin/bash

################################################################################
# Script: LawAdmin Environment Setup
#
# Description: This script sets up a development environment for the
# LawAdmin project
#
# WARNING: This script only works with Ghostty and MacOS since it relies
# on AppleScript to control the terminal.
#
# Version:  1.0.0
################################################################################

# Configuration variables
TERMINAL_APP="Ghostty"
PROJECT_ROOT="$HOME/DevProjects/lawadmin"
VENV_PATH="venv/bin/activate"
EDITOR_CMD="nvim ."
BACKEND_RUN_CMD="rpy"
EDITOR_QUIT_KEY="q"

validate_environment() {
    echo "Validating environment..."

    if [ ! -d "$PROJECT_ROOT" ]; then
        echo "Error: Project root directory not found: $PROJECT_ROOT"
        exit 1
    fi

    if [ ! -f "$PROJECT_ROOT/$VENV_PATH" ]; then
        echo "Error: Virtual environment not found: $VENV_PATH"
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

# Setup first tab: Project root with git pull and editor
execute_in_tab "1" "$PROJECT_ROOT" "
    keystroke \"source $VENV_PATH\" & return
    keystroke \"git pull\" & return
    keystroke \"$EDITOR_CMD\" & return
    keystroke \"$EDITOR_QUIT_KEY\" using {option down}
"

# Setup second tab: Backend with development server
execute_in_tab "2" "$PROJECT_ROOT" "
    keystroke \"source $VENV_PATH\" & return
    keystroke \"$BACKEND_RUN_CMD\" & return
"

exit 0
