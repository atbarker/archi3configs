#!/bin/sh

#if something throws an error
#set -e

#There is a card0-DP-1 and DP-2, same is the case with the HDMI-A-1 and HDMI-A-2

eDP_STATUS=$(</sys/class/drm/card0/card0-eDP-1/status )
HDMI_STATUS=$(</sys/class/drm/card0/card0-HDMI-A-1/status )
DP_STATUS=$(</sys/class/drm/card0/card0-DP-1/status )
VGA_STATUS=$(</sys/class/drm/card0/card0-VGA-1/status )

eDP_STATUS=$(</sys/class/drm/card0/card0-eDP-1/enabled )
HDMI_STATUS=$(</sys/class/drm/card0/card0-HDMI-A-1/enabled )
DP_STATUS=$(</sys/class/drm/card0/card0-DP-1/enabled )
VGA_STATUS=$(</sys/class/drm/card0/card0-VGA-1/enabled )

#check for the state log
if [ ! -f /tmp/monitor.log ]; then
	touch /tmp/monitor
	STATE=5
else
	STATE=$(</tmp/monitor)
fi

#the state log contains the next state to go in it

#Monitors are disconnected, stay in state 1
if [ "disconnected" = "$HDMI_STATUS" -a "disconnected" = "$DP_STATUS" -a "disconnected" = "$VGA_STATUS" ]; then
	STATE=1
fi

case $STATE in
	1)
	#eDP is on, nothing connected
	/usr/bin/xrandr --output eDP1 --auto
	STATE=2
	;;
	2)
	#eDP is on, projectors connected but not on
	/usr/bin/xrandr --output eDP1 --auto --output HDMI1 --off --output VGA1 --off --output DP1 --off
      	STATE=3
	;;
	3)
	#eDP is off, other things on
	if [ "connected" = "$HDMI_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --off --output HDMI1 --auto
		TYPE="HDMI"
	elif [ "connected" = "$DP_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --off --output DP1 --auto
		TYPE="DP"
	elif [ "connected" = "$VGA_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --off --output VGA1 --auto
		TYPE="VGA"
	fi
	/usr/bin/notify-send -t 5000 --urgency=low "Switched to $TYPE"
	STATE=4
	;;
	4)
	#eDP is on, mirroring
	if [ "connected" = "$HDMI_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --auto --output HDMI1 --auto
		TYPE="HDMI"
	elif [ "connected" = "$DP_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --auto --output DP1 --auto
		TYPE="DP"
	elif [ "connected" = "$VGA_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --auto --output VGA1 --auto
		TYPE="VGA"
	fi
	/usr/bin/notify-send -t 5000 --urgency=low "switched to $TYPE mirroring"
	STATE=5
	;;
	5)
	#eDP is on, extending
	if [ "connected" = "$HDMI_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --auto --output HDMI1 --auto --left-of eDP1
		TYPE="HDMI"
	elif [ "connected" = "$DP_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --auto --output DP1 --auto --left-of eDP1
		TYPE="DP"
	elif [ "connected" = "$VGA_STATUS" ]; then
		/usr/bin/xrandr --output eDP1 --auto --output VGA1 --auto --left-of eDP1
		TYPE="VGA"
	fi
	/usr/bin/notify-send -t 5000 --urgency=low "switched to $TYPE extended"
	STATE=2
	;;
	*)
	#this is strange, assume 1
	STATE=1
	;;
esac

echo $STATE > /tmp/monitor
