variable "proxmox_host" {
	type = string
}
variable "proxmox_nodename" {
	type    = string
	default = "proxmox"
}
variable "proxmox_token_id" {
	type = string
}
variable "proxmox_token_secret" {
	type      = string
	sensitive = true
}
variable "cloud_init_user" {
	type =  string
}
variable "cloud_init_ssh_keys" {
	type =  string
}
