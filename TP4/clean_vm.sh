#!/bin/bash





# remove previous nagios vm
virsh list --all | grep nagios
if [ $? -eq 0 ]
then
    virsh destroy nagios
    virsh undefine nagios
fi

# remove previous cible vm
virsh list --all | grep cible
if [ $? -eq 0 ]
then
    virsh destroy cible
    virsh undefine cible
fi


exit 0
