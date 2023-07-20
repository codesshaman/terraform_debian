terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = ">= 6.1.0"
    }
  }
}

provider "virtualbox" {
  source  = "terra-farm/virtualbox"
  version = ">= 6.1.0"
}

resource "virtualbox_vm" "debian" {
  name           = "debian-vm"
  memory         = 2048
  cpus           = 2
  boot_disk_size = 10240
}

resource "virtualbox_iso" "debian_iso" {
  name     = "debian-netinstall"
  source   = "debian-12.0.0-amd64-netinst.iso"
}

resource "virtualbox_storage_attach" "iso_attachment" {
  storage_controller_name = "IDE Controller"
  device_slot            = 1
  medium                 = virtualbox_iso.debian_iso.id
  vm_name                = virtualbox_vm.debian.name
}

resource "virtualbox_guest_additions" "debian_additions" {
  vm_name = virtualbox_vm.debian.name
}

resource "null_resource" "provision" {
  depends_on = [
    virtualbox_guest_additions.debian_additions,
  ]

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y docker",
      "apt-get install -y docker-compose",
      "apt-get install -y git"
    ]
  }
}