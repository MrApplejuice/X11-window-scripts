# A selection of handy X11/XFCE4 scripts

For personal use or use by anyone who is interested.

# Custom command templates for Thunar

Templates for integrating custom commands into thunar.

## Create image placeholder

~~~~~~~~~~~~~~
Name:     Generate a place holder image
Command:  

xfce4-terminal --color-bg="#FF7F7F" --color-text="#000000" --hide-menubar --hide-toolbar --hide-scrollbar --drop-down --title "Generate Placeholder" --working-directory=%f -e "bash /home/paul/myscripts/X11-window-scripts/dl-img-placeholder.sh"
~~~~~~~~~~~~~~
