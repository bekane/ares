#!/bin/bash

# Get alpine image and change the default root password
if [ ! -e alpine.img ]
then
    wget -O alpine.img https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/cloud/nocloud_alpine-3.20.3-x86_64-bios-cloudinit-r0.qcow2
    qemu-img resize alpine.img +150M
sudo /usr/bin/virt-customize -a alpine.img --root-password password:root
fi


# create libvirt new_pool if not exist
virsh pool-list | grep new_pool
if [ $? -eq 1 ]
then
    sudo mkdir -p /var/lib/libvirt/new_pool
    virsh pool-define-as new_pool dir --target /var/lib/libvirt/new_pool
    virsh pool-start new_pool
fi

#if [ ! -e nagios.img ]
#then
    sudo cp alpine.img /var/lib/libvirt/new_pool/cible.img
    sudo chown -R libvirt-qemu:kvm /var/lib/libvirt/new_pool/cible.img
#fi


cp cible.cfg user-data

cloud-localds cible.iso user-data

# remove previous cible vm
virsh list --all | grep cible
if [ $? -eq 0 ]
then
    virsh destroy cible
    virsh undefine cible
fi

# create cible
virt-install \
  --name cible \
  --ram 256 \
  --vcpus 1 \
  --disk path=/var/lib/libvirt/new_pool/cible.img,size=1 \
  --disk path=cible.iso,device=cdrom \
  --import --network network=lan1 \
  --os-type=linux --os-variant=alpinelinux3.8 \
  --graphics none --console pty,target_type=serial --noautoconsole

exit 0
