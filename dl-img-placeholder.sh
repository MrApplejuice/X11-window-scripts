#!/bin/bash

echo -n "Width: "
read width
echo -n "Height: "
read height
echo -n "Text: "
read text

if [ ! -z "$height" ] ; then
	height="x$height"
fi
if [ ! -z "$text" ] ; then
	text="?text=$( sed 's/ /+/g' <<< $text )"
fi

filename=
while [ -z "$filename" ] ; do
	echo -n "Filename: "
	read filename
done

colors=( 777/000 7ff/000 f7f/000 ff7/000 7f7/000 77f/000 f77/000 000/777 )
ci=$[ $RANDOM % ${#colors[@]} ]
color=${colors[$ci]}

url="$width$height/$color.png$text"

pwd
echo curl -o $filename.png https://via.placeholder.com/$url
curl -o $filename.png https://via.placeholder.com/$url

sleep 1
