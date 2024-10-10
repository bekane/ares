# Volume pour nagios
resource "libvirt_volume" "nagios_volume" {
  name = "nagios.img"
  base_volume_id = libvirt_volume.alpine_cloud.id
  format = "qcow2"
  pool   = libvirt_pool.new_pool.name
}


data "template_file" "user_data_nagios" {
  template = file("${path.module}/nagios.cfg")
  vars = {
           vm_name = "nagios"
  }
}

data "template_cloudinit_config" "config_nagios" {
  gzip = false
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.user_data_nagios.rendered}"
  }
}

resource "libvirt_cloudinit_disk" "nagios" {
  name            = "nagios.iso"
  pool   = libvirt_pool.new_pool.name
  user_data      = data.template_cloudinit_config.config_nagios.rendered
 # network_config  = data.template_file.network_config.rendered
}


# Machine virtuelle 1 (VM1)
resource "libvirt_domain" "nagios" {
  name   = "nagios"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.nagios.id

  network_interface {
    network_id   = libvirt_network.lan1.id
    hostname     = "nagios"
  }

  disk {
    volume_id = libvirt_volume.nagios_volume.id
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
