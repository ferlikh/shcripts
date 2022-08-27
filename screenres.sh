#!/bin/bash

if [ $(id -u) != 0 ]; then
    echo "Error: script needs to be run as root"
    exit 1
fi

HZ=60
WIDTH=1920
HEIGHT=1080
MONITORCONFFILE="/etc/X11/xorg.conf.d/10-monitor.conf"

gtfinfo=$(gtf $WIDTH $HEIGHT $HZ | grep Modeline | sed 's/  Modeline //')
resmode=$(echo $gtfinfo | awk '{print $1}' | sed 's/"//g')
resconfig=$(echo $gtfinfo | awk '{$1=""; print}')
display=$(xrandr -q | grep connected | head -1 | awk '{print $1}')

# adjust the screen resolution for the current session
xrandr --newmode $resmode $resconfig
xrandr --addmode $display $resmode
xrandr --output $display --mode $resmode

# save the monitor config so the settings persist
monitorconf="Section \"Monitor\"\n"
monitorconf+="\tIdentifier \"$display\"\n"
monitorconf+="\tModeline $gtfinfo\n"
monitorconf+="\tOption \"PreferredMode\" \"$resmode\"\n"
monitorconf+="EndSection\n"

printf "$monitorconf" > "$MONITORCONFFILE"