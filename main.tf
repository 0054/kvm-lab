provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_domain" "vms" {
  for_each  = var.vm_config
  name      = each.key
  vcpu      = each.value["vcpu"]
  memory    = each.value["memory"]
  arch      = "x86_64"
  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  disk {
    volume_id = "${libvirt_volume.vm_disk[each.key].id}"
    scsi      = true
  }

  network_interface {
    network_id     = libvirt_network.terraform_network.id
    hostname       = each.key
    addresses      = each.value["ip"]
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  boot_device {
    dev = ["hd", "network"]
  }
  autostart = false
}


resource "libvirt_network" "terraform_network" {
  name      = "terraform_network"
  autostart = true
  mode      = "nat"
  domain    = var.network_config["domain"]
  addresses = var.network_config["addresses"]
  # dhcp {
  #   enabled = true
  # }
  dns {
    enabled    = true
    local_only = false
  }
}

resource "libvirt_pool" "terraform_pool" {
  name = var.pool_config["name"]
  type = "dir"
  path = var.pool_config["path"]
}

resource "libvirt_volume" "centos_template" {
  name = "centos_template"
  pool = libvirt_pool.terraform_pool.name
  # https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1907.qcow2
  source = "/kvm-pool/images/CentOS-7-x86_64-GenericCloud-1907.qcow2"
}

resource "libvirt_volume" "vm_disk" {
  for_each       = var.vm_config
  name           = "${each.key}_disk"
  size           = each.value["disk"] * 1024 * 1024 * 1024
  base_volume_id = "${libvirt_volume.centos_template.id}"
  pool           = libvirt_pool.terraform_pool.name
}

data "template_file" "user_data" {
  template = file("./user_data_cloud_init.yml")
  vars = {
    rsa_pub = file("./rsa/id_rsa.pub")
  }
}

data "template_file" "network_config" {
  template = file("./network_config_cloud_init.yml")
  for_each = var.vm_config
  vars = {
    ip = each.value["ip"].0
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each       = var.vm_config
  name           = "${each.key}_cloudinit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config[each.key].rendered
  pool           = libvirt_pool.terraform_pool.name
}

