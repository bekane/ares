#!/bin/bash

# Get alpine image and change the default root password
if [ ! -e alpine.img ]
then
    wget -O alpine.img https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/cloud/nocloud_alpine-3.20.3-x86_64-bios-cloudinit-r0.qcow2
    qemu-img resize alpine.img +250M
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
    sudo cp alpine.img /var/lib/libvirt/new_pool/nagios.img
    sudo chown -R libvirt-qemu:kvm /var/lib/libvirt/new_pool/nagios.img
#fi


cp nagios.cfg user-data

cloud-localds nagios.iso user-data

# remove previous nagios vm
virsh list --all | grep nagios
if [ $? -eq 0 ]
then
    virsh destroy nagios
    virsh undefine nagios
fi

# create nagios
virt-install \
  --name nagios \
  --ram 256 \
  --vcpus 1 \
  --disk path=/var/lib/libvirt/new_pool/nagios.img,size=1 \
  --disk path=nagios.iso,device=cdrom \
  --import --network network=lan1 \
  --os-type=linux --os-variant=alpinelinux3.8 \
  --graphics none --console pty,target_type=serial --noautoconsole

exit 0
