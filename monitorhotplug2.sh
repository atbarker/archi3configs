#!/bin/sh

#if something throws an error
#set -e

#works on thinkpad t440p running arch linux with the i3 window manager
#There is a card0-DP-1 and DP-2, same is the case with the HDMI-A-1 and HDMI-A-2
#The names according to xrandr ar DP1, DP2, VGA1, VGA2, HDMI1,HDMI2, and eDP1

eDP_STATUS=$(</sys/class/drm/card0/card0-eDP-1/status )
HDMI_STATUS=$(</sys/class/drm/card0/card0-HDMI-A-1/status )
DP_STATUS=$(</sys/class/drm/card0/card0-DP-1/status )
VGA_STATUS=$(</sys/class/drm/card0/card0-VGA-1/status )

if [[ $HDMI_STATUS = connected ]]; then
	/usr/bin/xrandr --output HDMI1 --left-of eDP1 --auto
	/usr/bin/xrandr --output DP1 --off
	/usr/bin/xrandr --output VGA1 --off
	/usr/bin/notify-send --urgency=low -t 5000 "HDMI plugged in"
elif [[ connected = $DP_STATUS ]]; then
	/usr/bin/xrandr --output DP1 --left-of eDP1 --auto
	/usr/bin/xrandr --output HDMI1 --off
	/usr/bin/xrandr --output VGA1 --off
	/usr/bin/notify-send --urgency=low -t 5000 "DisplayPort plugged in"
elif [[ connected = $VGA_STATUS ]]; then
	/usr/bin/xrandr --output VGA1 --left-of eDP1 --auto
	/usr/bin/xrandr --output DP1 --off
	/usr/bin/xrandr --output HDMI1 --off
	/usr/bin/notify-send --urgency=low -t 5000 "VGA plugged in"
else 
	/usr/bin/xrandr --output HDMI1 --off
	/usr/bin/xrandr --output DP1 --off
	/usr/bin/xrandr --output VGA1 --off
	/usr/bin/notify-send --urgency=low -t 5000 "Monitor unplugged"
	exit
fi
