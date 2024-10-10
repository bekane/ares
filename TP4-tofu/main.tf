terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}


resource "libvirt_network" "lan1" {
  name      = "lan1"
  addresses = ["192.168.101.0/24"]
}


resource "libvirt_pool" "new_pool" {
  name = "new_pool"
  type = "dir"
  path = "/var/lib/libvirt/new_pool"
}

# Image base Alpine Cloud
resource "libvirt_volume" "alpine_cloud" {
  name = "alpine.img"
  source = "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/cloud/nocloud_alpine-3.20.3-x86_64-bios-cloudinit-r0.qcow2"
  #source = "alpine.qcow2"
  format = "qcow2"
  pool   = libvirt_pool.new_pool.name
}
