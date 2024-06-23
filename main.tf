terraform {
	required_providers {
		proxmox = {
			source  = "telmate/proxmox"
			version = "3.0.1-rc3"
		}
		ansible = {
			version = "~> 1.3.0"
			source  = "ansible/ansible"
		}
	}
}

resource "proxmox_vm_qemu" "foreman" {
	name        = "foreman"
	target_node = var.proxmox_nodename
	desc        = "Foreman server"  
	onboot      = true
	clone       = "rocky9-template"
	memory      = 6144
	cores       = 3
	os_type     = "cloud_init"
	ciuser      = var.cloud_init_user
	sshkeys     = var.cloud_init_ssh_keys
	ipconfig0   = "ip=10.1.43.2/24,gw=10.1.43.1"
	nameserver  = "10.1.43.1"

	disks {
		virtio {
			virtio0 {
				disk {
					size = "20G"
					storage = "local-zfs"
				}
			}
		}
		ide {
			ide1 {
				cloudinit {
					storage = "local-zfs"
				}
			}
		}
	}

	network {
		bridge = "vmbr43"
		model  = "virtio"
	}
}

resource "ansible_host" "foreman" {
	name = proxmox_vm_qemu.foreman.name
	groups = ["terraform", "foreman"]
	variables = {
		ansible_user = var.cloud_init_user
		ansible_host = regex(".*ip=(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}).*", proxmox_vm_qemu.foreman.ipconfig0)[0]
	}
}

