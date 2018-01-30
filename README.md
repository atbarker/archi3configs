# archi3configs

Hotplugging displays:

In order for hotplugging to work one must use a udev rule. This is contained in the file 98-monitor-hotplug.rules.

To get a list of devices type the following.
ls /sys/class/drm/card0

To determine the status of the device run this:

echo $(</sys/class/drm/card0/card0-<device>/status)

