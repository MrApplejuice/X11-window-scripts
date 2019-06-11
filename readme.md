# A selection of handy X11/XFCE4 scripts

For personal use or use by anyone who is interested.

# Custom command templates for Thunar

Templates for integrating custom commands into thunar.

## Create image placeholder

~~~~~~~~~~~~~~
Name:     Generate a place holder image
Command:  xfce4-terminal --color-bg="#FF7F7F" --color-text="#000000" --hide-menubar --hide-toolbar --hide-scrollbar --drop-down --title "Generate Placeholder" --working-directory=%f -e "bash /home/paul/myscripts/X11-window-scripts/dl-img-placeholder.sh"
~~~~~~~~~~~~~~

## Shortcut window

Required installed software:

- xdotool
- notify-send
- zenity

Allows binding keys to windows to activate a given window and send arbitrary
keyboard inputs to a shortcutted window. The window-manager need to be used
in to create keybindings for invoking the script.

Usage:

`shortcut-window.sh store [key]`

Stores the currently active window under name `[key]`.

`shortcut-window.sh activate [key]`

Activates the windows stored under name `[key]`.

`shortcut-window.sh rec_key [key] [shortcut-key]`

Creates a keysequence to be sent to window bound to name `[key]`. The name of 
the stored keysequence will be `[shortcut-key]`.

`shortcut-window.sh send_key [shortcut-key]`

Sends the named keysequence `[shortcut-key]` to the window that was associated
with the keysequence using `rec_key`.

