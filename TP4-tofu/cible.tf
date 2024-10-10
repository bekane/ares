# Volume pour cible
resource "libvirt_volume" "cible_volume" {
  name = "cible.img"
  base_volume_id = libvirt_volume.alpine_cloud.id
  format = "qcow2"
  pool   = libvirt_pool.new_pool.name
}


data "template_file" "user_data_cible" {
  template = file("${path.module}/cible.cfg")
  vars = {
           vm_name = "cible"
  }
}

data "template_cloudinit_config" "config_cible" {
  gzip = false
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.user_data_cible.rendered}"
  }
}

resource "libvirt_cloudinit_disk" "cible" {
  name            = "cible.iso"
  pool   = libvirt_pool.new_pool.name
  user_data      = data.template_cloudinit_config.config_cible.rendered
 # network_config  = data.template_file.network_config.rendered
}


# Machine virtuelle 1 (VM1)
resource "libvirt_domain" "cible" {
  name   = "cible"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.cible.id

  network_interface {
    network_id   = libvirt_network.lan1.id
    hostname     = "cible"
  }

  disk {
    volume_id = libvirt_volume.cible_volume.id
  }


  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
  }
}
