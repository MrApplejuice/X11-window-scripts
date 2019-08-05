#!/bin/bash

# Modifies the volme of the default sink using a given percentage (as parameter)

export LC_ALL=C

percentage=$(sed 's/\%//g' <<< "$1")

if [ -z "$percentage" ] ; then
  echo "Error: percentage delta expected"
  exit 1
fi

# Find the default output sink

default_sink=$(pactl info | grep 'Default Sink: ' | sed 's/Default Sink: //')
if [ -z "$default_sink" ] ; then
  echo "Error: no default sink found"
  exit 2
fi

# Find current volume

#volume_channel_sum=$[ 0 $(pacmd info | grep -A 20 "name: *<$default_sink>" | grep 'volume: ' | head -n +1 | sed -E 's/[^\%]*://g;s/\%//g;s/ +/ + /g') ]
volume_channel_sum=$[ 0 $(pacmd info | grep -A 20 "name: *<$default_sink>" | grep 'volume: ' | head -n +1 | sed -E ':x;s/(^|\/)[^\%]*($|\/)//g;s/\%/ + /g;s/^/+/;:y;s/  / /;t y;s/[ +]*$//') ]
volume=$[ $volume_channel_sum / 2 ]

new_volume=$[ $volume + $percentage ]

if [ $new_volume -lt 0 ] ; then
  new_volume=0
fi
if [ $new_volume -gt 100 ] ; then
  new_volume=100
fi

pactl set-sink-volume "$default_sink" "${new_volume}%"

echo "Changed volume of $default_sink to ${new_volume}%"
echo "Old volume was ${volume}%"
