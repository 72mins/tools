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
# Version:  1.0
################################################################################

new_tab='
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "t" using {command down}
    end tell
end tell
'

first_tab='
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "1" using {command down}
    end tell
    tell application "System Events"
        keystroke "cd ~/DevProjects/sentinel" & return
        keystroke "source backend/.venv/bin/activate" & return
        keystroke "git pull" & return
        keystroke "nvim ." & return
        keystroke "q" using {option down}
    end tell
end tell
'

second_tab='
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "2" using {command down}
    end tell
    tell application "System Events"
        keystroke "cd ~/DevProjects/sentinel/backend" & return
        keystroke "source .venv/bin/activate" & return
        keystroke "uvi project" & return
    end tell
end tell
'

third_tab='
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "3" using {command down}
    end tell
    tell application "System Events"
        keystroke "cd ~/DevProjects/sentinel/web" & return
        keystroke "bun run dev" & return
    end tell
end tell
'

osascript -e "$new_tab"
osascript -e "$new_tab"

osascript -e "$first_tab"
osascript -e "$second_tab"
osascript -e "$third_tab"

exit 0
