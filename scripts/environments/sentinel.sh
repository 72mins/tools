#!/bin/bash

################################################################################
# Script: Sentinel Environment Setup
#
# Description: This script sets up a development environment for the
# Sentinel project
#
# WARNING: This script only works with Ghostty and MacOS since it relies
# on AppleScript to control the terminal.
#
# Version:  1.1.0
################################################################################

# Configuration variables
TERMINAL_APP="Ghostty"
PROJECT_ROOT="$HOME/DevProjects/sentinel"
BACKEND_PATH="$PROJECT_ROOT/backend"
WEB_PATH="$PROJECT_ROOT/web"
VENV_PATH=".venv/bin/activate"
EDITOR_CMD="nvim ."
BACKEND_RUN_CMD="uvi project"
WEB_RUN_CMD="bun run dev"
EDITOR_QUIT_KEY="q"

validate_environment() {
    echo "Validating environment..."

    if [ ! -d "$PROJECT_ROOT" ]; then
        echo "Error: Project root directory not found: $PROJECT_ROOT"
        exit 1
    fi

    if [ ! -d "$BACKEND_PATH" ]; then
        echo "Error: Backend directory not found: $BACKEND_PATH"
        exit 1
    fi

    if [ ! -d "$WEB_PATH" ]; then
        echo "Error: Web directory not found: $WEB_PATH"
        exit 1
    fi

    if [ ! -f "$BACKEND_PATH/$VENV_PATH" ]; then
        echo "Error: Virtual environment not found: $BACKEND_PATH/$VENV_PATH"
        exit 1
    fi

    if [ ! -f "$WEB_PATH/package.json" ]; then
        echo "Error: Web package.json not found in: $WEB_PATH"
        exit 1
    fi

    if ! command -v bun &>/dev/null; then
        echo "Error: bun command not found. Please install bun."
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

# Setup first tab: Project root with git pull and editor
execute_in_tab "1" "$PROJECT_ROOT" "
    keystroke \"source backend/$VENV_PATH\" & return
    keystroke \"git pull\" & return
    keystroke \"$EDITOR_CMD\" & return
    keystroke \"$EDITOR_QUIT_KEY\" using {option down}
"

# Setup second tab: Backend with development server
execute_in_tab "2" "$BACKEND_PATH" "
    keystroke \"source $VENV_PATH\" & return
    keystroke \"$BACKEND_RUN_CMD\" & return
"

# Setup third tab: Web with development server
execute_in_tab "3" "$WEB_PATH" "
    keystroke \"$WEB_RUN_CMD\" & return
"

exit 0
