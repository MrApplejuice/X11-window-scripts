#!/bin/bash

# This tool allows a user to create a shortcut to quickly activate a certain
# window in X11. Window key shortcuts are registered globally, therefore, one
# will also jump to a given window if it is on a different virtual desktop.

# Required software: xdotool

# Commands

# shortcut-window.sh store name
# 
# Store the currently active window under the given `name`.

# shortcut-window.sh activate name
#
# Activates the window stored under the given name. Does nothing if the window 
# cannot be found)

# TODO
# - Implement heuristic title-based search if now window can be found with a
#   given id.

config_file="$HOME/.config/shortcut-win.data"
if [ ! -e "$config_file" ] ; then
    touch "$config_file"
fi

if [ "$1" == "store" ] ; then
    if [ -z "$2" ] ; then
         notify-send --urgency=low -i error "No name for window specified."
        exit 1
    fi
    
    if ! winid=$(xdotool getactivewindow) ; then
         notify-send --urgency=low -i error "No active window found."
         exit 1
    fi
    
    name=$( tr -dc '[a-zA-Z0-9]' <<< "$2" )
    grep -v "^$name " $config_file > $config_file.2
    mv $config_file.2 $config_file
    echo "$name $winid" >> $config_file
    
    notify-send --urgency=low -i info "Assinged '$name' => '`xdotool getwindowname $winid`'"
    
    exit 0
fi

if [ "$1" == "activate" ] ; then
    name=$( tr -dc '[a-zA-Z0-9]' <<< "$2" )
    if ! line=$( grep "^$name " $config_file ) ; then
         notify-send --urgency=low -i error "No window stored using name '$name'"
         exit 1
    fi
    winid=$( awk '{ print $2 }' <<< "$line" )
    if ! xdotool windowactivate $winid ; then
         notify-send --urgency=low -i error "No window stored using name '$name'"
         exit 1
    fi
    exit 0
fi

echo "Invalid argument: $1"
exit 1