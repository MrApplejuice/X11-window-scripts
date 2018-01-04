#!/bin/bash

declare -A resolutions

tmpfile=$(mktemp)

xrandr --listactivemonitors | \
    sed -En 's!^.* ([0-9]+)/[0-9]+x([0-9]+)/[0-9]+\+([0-9]+)\+([0-9]+).*$!\1 \2 \3 \4!;Te;p;:e' > $tmpfile

count=0
while read width height xoffset yoffset; do
    resolutions["width_$count"]=$width  
    resolutions["height_$count"]=$height  
    resolutions["xoffset_$count"]=$xoffset  
    resolutions["yoffset_$count"]=$yoffset
    resolutions["xmax_$count"]=$[ $xoffset + $width ]
    resolutions["ymax_$count"]=$[ $yoffset + $height ]
    count=$[ $count + 1 ]
done < $tmpfile 
rm $tmpfile



window_id=$(xdotool getactivewindow)


function echo_location {
    xdotool getwindowgeometry $window_id | \
        grep Position | \
        sed -En 's/.*Position.* ([0-9]+),([0-9]+).*$/\1 \2/;Te;p;:e'
}

echo_location > $tmpfile ; read window_x window_y < $tmpfile ; rm $tmpfile

for i in $(seq -s" " 0 $[ $count - 1 ] ) ; do
    if [ $window_x -ge ${resolutions["xoffset_$i"]} ] && \
      [ $window_x -lt ${resolutions["xmax_$i"]} ] && \
      [ $window_y -ge ${resolutions["yoffset_$i"]} ] && \
      [ $window_y -lt ${resolutions["ymax_$i"]} ] ; then
        if [ "$1" == "prev" ] ; then
            nexti=$[ $i - 1 ]
        else
            nexti=$[ $i + 1 ]
        fi
        if [ $nexti -lt 0 ] ; then
            nexti=$[ $count - 1 ]
        fi
        if [ $nexti -ge $count ] ; then
            nexti=0
        fi
         
        offset_x=$[ $window_x - ${resolutions["xoffset_$i"]} ]
        offset_y=$[ $window_y - ${resolutions["yoffset_$i"]} ]
         
        newx=$[ $offset_x + ${resolutions["xoffset_$nexti"]} ]
        newy=$[ $offset_y + ${resolutions["yoffset_$nexti"]} ]
        xdotool windowmove -sync \
           $window_id $newx $newy
    
        echo_location > $tmpfile ; read window_x window_y < $tmpfile ; rm $tmpfile
         
        echo "On screen $i"
        echo "Moving to screen $nexti"
        echo "  moving to x=$newx y=$newy"
        echo "  arrived at x=$window_x y=$window_y"
         
        fixed_x_offset=$[ $window_x - $newx ]
        fixed_y_offset=$[ $window_y - $newy ]
        if [ ! $fixed_x_offset -eq 0 ] || [ ! $fixed_x_offset -eq 0 ] ; then
            echo "  ...arrived at different location... fixing"
            xdotool windowmove -sync \
               $window_id \
               $[ $newx - $fixed_x_offset ] \
               $[ $newy - $fixed_y_offset ]
               
            echo_location > $tmpfile ; read window_x window_y < $tmpfile ; rm $tmpfile
            echo "  fixed location: x=$window_x y=$window_y"
        fi
         
        break
    fi
done