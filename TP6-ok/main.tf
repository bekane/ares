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

# Réseau pour Client à Target
resource "libvirt_network" "client_router_net" {
  name      = "lan1"
  addresses = ["<CLIENT_ROUTER>/24"]
  dns {
    local_only = true
    enabled = true
  }
}

resource "libvirt_network" "router_target_net" {
  name      = "lan2"
  addresses = ["<ROUTER_TARGET>/24"]
  dns {
    local_only = true
    enabled = true
  }
}


resource "libvirt_network" "router_internet_net" {
  name      = "lan3"
  addresses = ["<ROUTER_INTERNET>/24"]
  dns {
    local_only = true
    enabled = true
  }
}


# Pool de stockage pour les disques des VMs
resource "libvirt_pool" "new_pool" {
  name = "new_pool"
  type = "dir"
  path = "/var/lib/libvirt/new_pool"
}

# Image de base Alpine pour les VMs
resource "libvirt_volume" "alpine_cloud" {
  name   = "alpine.qcow2"
  source = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/cloud/nocloud_alpine-3.18.9-x86_64-bios-cloudinit-r0.qcow2"
  format = "qcow2"
  pool   = libvirt_pool.new_pool.name
}

# Définir une liste des machines (Client, Routeur, Target)
locals {
  machines = {
    client  = { name = "client", size = 409715200}
    router  = { name = "router", size = 409715200}
    target  = { name = "target", size = 409715200}
  }
}

# Boucle pour générer les volumes pour chaque machine
resource "libvirt_volume" "vm_volumes" {
  for_each        = local.machines
  name            = "${each.value.name}.qcow2"
  base_volume_id  = libvirt_volume.alpine_cloud.id
  format          = "qcow2"
  pool            = libvirt_pool.new_pool.name
  size            = each.value.size
}

data "template_file" "cloud_init" {
for_each = local.machines
  template = <<EOF
#cloud-config
users:
  - name: root
    ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1vtGUUZaFa6hjZfV1HpnNdQNJMxgSEmvYh6UWHCRnNb3PeZPb5DSoTuCK+EfJX8B91y1CZz1CvG4gH9b6MEo0vSlFbvxz1BgLtLH8z9MnHMgtt6wYciQNPknSmlBVVb1Ozj6ttzsLFo9g2DQQJtKTkV5KbCUm5x2S6znehiHB2sD6mTsyVyJoWHkYCMo7+c+/uD5vWtaL+tdHCNiKBTeISsyxXYIpuj4DuAdDvQS/6MkHK2Z+MEG2g2Hw7YnhgyvYBov5KJLbObBOfNXZZRp23YfErV1OKzjvGQOTCN91vqV4JE9gKIcqbqD2Xy9O6JREfQGTbrb+nulcVtZ2GrTm0cKDHrLMEPM9TDn9az5HpXgzwC3UMxE9EXSMakak5Y7WfJqJrd2W/l/tCNLS2aWLHF/2YpxBJ2V9l3NyQS7ORNJpxQve4VUnqC+NELNYO7NlNY/cqM/liZFL/D9uOjy/l31HA6uSY33+Y+p147VqHVQKa4IVsJQx8dhaUnbUjVs= bekaneap@ptb-12g0s54.irisa.fr
chpasswd:
  list: |
    root:root
  expire: False
fqdn: ${each.value.name}
write_files:
  - path: /run/scripts/net.sh
    content: |
        #!/bin/sh
        case `hostname -s` in
        client)
        cat>/etc/network/interfaces<<EOT
          auto lo
          iface lo inet loopback
          auto eth0
          iface eth0 inet static
              address ........
              netmask 255.255.255.0
              gateway ........
              dns-nameservers 8.8.8.8
        EOT
        ;;
        target)
        cat>/etc/network/interfaces<<EOT
          auto lo
          iface lo inet loopback
          auto eth0
          iface eth0 inet static
              address ........
              netmask 255.255.255.0
              gateway ........
              dns-nameservers 8.8.8.8
        EOT
        ;;
        router)
        cat>/etc/network/interfaces<<EOT
          auto lo
          iface lo inet loopback
          auto eth0
          iface eth0 inet static
              address ..........
              netmask 255.255.255.0
          auto eth1
          iface eth1 inet static
              address ..........
              netmask 255.255.255.0

          auto eth2
          iface eth2 inet static
              address ..........
              netmask 255.255.255.0
              gateway ..........
              dns-nameservers 8.8.8.8
        EOT

        sysctl -w net.ipv4.ip_forward=1
        # clear rules
        iptables -D FORWARD -i eth0 -o eth2 -j ACCEPT
        iptables -D FORWARD -i eth1 -o eth2 -j ACCEPT
        iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE

        #Enable router to route client and target flow to internet 
        iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
        iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
        iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE

        ;;
        esac;

        exit 0
    permissions: 0777
runcmd:
  - resize2fs /dev/vda
  - /run/scripts/net.sh # run the net.sh script
  - /sbin/service networking restart # apply network configuration
EOF
}


# Cloud-init ISO pour passer la configuration réseau à la VM
resource "libvirt_cloudinit_disk" "isos" {
  for_each        = local.machines
  name           = "${each.value.name}.iso"
  pool            = libvirt_pool.new_pool.name
  user_data      = data.template_file.cloud_init[each.key].rendered
}



# VM Client (Machine A)
resource "libvirt_domain" "client" {
  name   = "client"
  memory = 512
  vcpu   = 1
  network_interface {
    network_id = libvirt_network.client_router_net.id
    hostname   = "client"
    mac = ".............."
  }

  disk {
    volume_id = libvirt_volume.vm_volumes["client"].id
  }
  cloudinit = libvirt_cloudinit_disk.isos["client"].id
    console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # Configuration d'un affichage graphique (ici, Spice est utilisé)
  graphics {
    type = "spice"
  }
}

# VM Target (Machine B)
resource "libvirt_domain" "target" {

  name   = "target"
  memory = 512
  vcpu   = 1

  network_interface {
    network_id = libvirt_network.router_target_net.id
    hostname   = "target"
    mac = ".............."
  }

  disk {
    volume_id = libvirt_volume.vm_volumes["target"].id
  }

  cloudinit = libvirt_cloudinit_disk.isos["target"].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # Configuration d'un affichage graphique (ici, Spice est utilisé)
  graphics {
    type = "spice"
  }
}



# VM Router (Machine C)
resource "libvirt_domain" "router" {

  name   = "router"
  memory = 512
  vcpu   = 1

  network_interface {
    network_id = libvirt_network.client_router_net.id
    hostname   = "router"
    mac = "................"
  }

  network_interface {
    network_id = libvirt_network.router_target_net.id
    hostname   = "router"
    mac = "................."
  }

  network_interface {
    network_id = libvirt_network.router_internet_net.id
    hostname   = "router"
    mac = "..............."
  }

  disk {
    volume_id = libvirt_volume.vm_volumes["router"].id
  }

  cloudinit = libvirt_cloudinit_disk.isos["router"].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  # Configuration d'un affichage graphique (ici, Spice est utilisé)
  graphics {
    type = "spice"
  }
}
