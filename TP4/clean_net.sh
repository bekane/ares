#!/bin/bash


# list tous les réseaux et supprime si différent de default


for net in $(virsh net-list --all --name | grep -v default); do
    virsh net-destroy $net
    virsh net-undefine $net
done


exit 0

