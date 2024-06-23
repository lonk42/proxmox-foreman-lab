# Using terraform

## Setup
```
terraform init
```

## Usage
```
terraform plan
terraform apply
ansible-playbook -i ansible/inventory/ ansible/playbook.yml --limit <hostname> --diff
```

# Ansible
```
ansible-galaxy install -r requirements.yaml
```

# Proxmox

## Initial Setup

### Download Cloud Image
```
zfs create rpool/cloud-images -o mountpoint=/rpool/cloud-images/
cd /rpool/cloud-images
wget http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-LVM-9.4-20240609.0.x86_64.qcow2
```

### Create a template VM from the image
```
TEMPLATE_ID=1000
qm create $TEMPLATE_ID --memory 2048 --net0 virtio,bridge=vmbr0 --name rocky9-template
qm set $TEMPLATE_ID --virtio0 local-zfs:0,import-from=/rpool/cloud-images/Rocky-9-GenericCloud-LVM-9.4-20240609.0.x86_64.qcow2
qm set $TEMPLATE_ID --ide1 local-zfs:cloudinit
qm set $TEMPLATE_ID --boot order=virtio0
qm template $TEMPLATE_ID
```

### Creating terraform user (https://registry.terraform.io/providers/Terraform-for-Proxmox/proxmox/latest/docs)
```
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
pveum user add terraform-prov@pve 
pveum aclmod / -user terraform-prov@pve -role TerraformProv
pveum user token add terraform-prov@pve terraform --privsep 0
```
