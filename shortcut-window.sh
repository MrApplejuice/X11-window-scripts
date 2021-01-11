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


config_file="$HOME/.config/shortcut-win.data"
if [ ! -e "$config_file" ] ; then
    touch "$config_file"
fi

function clear_name() {
    tr -dc '[a-zA-Z0-9]' <<< "$1"
}

function find_window() {
    name=$( clear_name "$1" )
    if ! line=$( grep "^$name " $config_file ) ; then
         notify-send --urgency=low -i error "No window stored using name '$name'"
         exit 1
    fi
    winid=$( awk '{ print $2 }' <<< "$line" )
    if ! xdotool getwindowname $winid > /dev/null ; then
         notify-send --urgency=low -i error "No window stored using name '$name'"
         exit 1
    fi
    echo $winid
}

if [ "$1" == "help" ] || [ "$1" == "--help" ]; then
    cat <<EOF
shortcut-window.sh command [command-args]

Utility that allows to assign keys to open X-windows and send keyboard
shortcuts to keyed windows. It is particular useful when used in with
custom shortcuts in a window manager. This tool then can be used to assign
keyboard shortcuts to windows like in a RTS game.

Commands:

store key         Store the currently active window under the key
                  `key`. Example: "shortcut-window.sh store window-1"
activate key      Activate the window that is stored udner the
                  given `key` name. Example:
                  "shortcut-window.sh activate window-1"
rec_key key keyid Store a key combination that can be sent to a window
                  that as an assigned key `key` refers to the name of
                  a key assigned to a window using the "store" command.
                  `keyid` is an identifier that is used to store the
                  key under. A popup will be shown that allows a user
                  to enter a key combination that sahll be sent to the
                  window that `key` refers to. The combination of
                  window+shortcut will be stored under the key `keyid`.
send_key keyid    Send the previously stored key combination to the 
                  stored window.
EOF
    exit 0
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
    
    name=$( clear_name "$2" )
    grep -v "^$name " $config_file > $config_file.2
    mv $config_file.2 $config_file
    echo "$name $winid" >> $config_file
    
    notify-send --urgency=low -i info "Assigned '$name' => '`xdotool getwindowname $winid`'"
    
    exit 0
fi

if [ "$1" == "activate" ] ; then
    if ! winid=$(find_window "$2") ; then
        exit 1
    fi
    xdotool windowactivate $winid
    exit 0
fi

if [ "$1" == "rec_key" ] ; then
    win_key_name=$( clear_name "$2" )
    if ! winid=$(find_window "$win_key_name") ; then
        exit 1
    fi
    window_name="$(xdotool getwindowname $winid)"
    
    name=$( clear_name "$3" )
    if [ -z "$name" ] ; then
         notify-send --urgency=low -i error "No keyid provided for rec_key command (3rd argument)"
         exit 1
    fi
    if ! key="$(zenity --entry --text='Key combination to send to window on '"'$win_key_name'"' for keyid '"'$name'")" ; then
        exit 0
    fi
    key=$( tr -d '[:blank:]' <<< "$key" )
    
    grep -v "^!rec_key $name " $config_file > $config_file.2
    mv $config_file.2 $config_file
    echo "!rec_key $name $win_key_name $key" >> $config_file
    
    notify-send --urgency=low -i info "Registered sending key(s) '$key' to window '$window_name' under keyid '$name'"
    exit 0
fi

if [ "$1" == "send_key" ] ; then
    name=$( clear_name "$2" )
    if ! line=$(grep "\\!rec_key $name " $config_file) ; then
         notify-send --urgency=low -i error "No key bound for keyid '$name'"
         exit 1
    fi
    read _ _ win_key_name key <<< "$line"
    if ! winid=$( find_window "$win_key_name" ) ; then
        exit 1
    fi
    
    xdotool key --clearmodifiers --delay 100 --window $winid $( sed 's/,/ /g' <<< "$key" )
    exit 0
fi

echo "Invalid argument: $1 (use --help to show help)"
exit 1
