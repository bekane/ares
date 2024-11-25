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

# Réseau pour Client à Routeur
resource "libvirt_network" "cible_router_net" {
  name      = "vxlan_net_100"
  addresses = ["192.168.10.0/24"]
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
    cible  = { name = "cible", size = 409715200}
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
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/t6fIwdrfR4FZObYTVkrsOTHE78cnHZ1CiArS5ui9HNyjA2RfEqddvcYAEHpdpOQAIl+vAYzN2OuGTxzYSWjKYCLpfUiLtJR7HAKHoydeJyTVVUisuaMJ1ainOs5n//cFwzTfKl/V4vDDZzGvtTetnpaPGN/t7td4asFNr3lMhWK6stn6HGDT4wkVkeFDBeJ/b9xdOkUbdqWcFtIzTPZpf02TaC5S6wewjVVD9GpxLrdLx4JpZKfy6kZdU1cuSt3hIdsLKD4Pzz7UPV3dTWyOzWOydRbGCbvwnxtXioZffpVcMBTARIVYG/R+Xxm7o8ZZIzrXD/GEln6GORjJoNci2+R1+s8cdA8sYSHxZxdrVsfogynprXBWeGd17cLs41GHDqwPBYXkdKNOM6X+bgZczmF6FHFl4mLIz/M4urcQAqebJCsRu1gXIP4JRX8X11ZtZ3qMKgS77pEnhelgWvXT44Oomy1bcMgr55HO/a/WdA/+/vw1as+afzJmrxn+1Ad/79z+c0FJ20npN1PQc2Fd4GSXnG4wRq00lva80Xo7aEWZ3q6REJJvo9nYYOYFYGbsddUftMopdKnW98r9f+35eDYyUw5MDtKP44Hixaxn+i9yk4tUJxCeLjPWbbMZFO214tPpRqqNrg/fbprYUT/+ezzkj4HB8eeuRQwtGUeCxw== consultant@nepturne
chpasswd:
  list: |
    root:root
  expire: False
fqdn: ${each.value.name}
write_files:
  - path: /etc/ssh/sshd_config.d/50-cloud-init.conf
    content: |
        PubkeyAuthentication yes
        PasswordAuthentication yes  # Si tu veux utiliser l'authentification par mot de passe
        ChallengeResponseAuthentication yes
        PermitRootLogin yes
  - path: /etc/network/interfaces
    content: |
      auto lo
runcmd:
  - resize2fs /dev/vda
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
resource "libvirt_domain" "cible" {
  name   = "cible"
  memory = 1024
  vcpu   = 4
  network_interface {
    network_id = libvirt_network.cible_router_net.id
    hostname   = "cible"
    mac = "52:54:00:6b:3b:04"
  }

  disk {
    volume_id = libvirt_volume.vm_volumes["cible"].id
  }
  cloudinit = libvirt_cloudinit_disk.isos["cible"].id
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
