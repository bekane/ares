#!/bin/bash

# create default lan

virsh net-define lan1.xml
virsh net-start lan1
virsh net-autostart lan1


exit 0

