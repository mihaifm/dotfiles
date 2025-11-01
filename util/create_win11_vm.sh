#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 autounattend.xml"
  exit 1
fi

##############
# Config area

DISK_STORE="local-lvm"
ISO_PATH="/var/lib/vz/template/iso"
WIN_ISO="${ISO_PATH}/Win11_25H2_NoPrompt.iso"
VIRTIO_ISO="${ISO_PATH}/virtio-win-0.1.285.iso"

VM_CORES=4
VM_DISK_SIZE=64  # GB
BRIDGE="vmbr0"

# Max memory (MB) visible to guest
VM_RAM_MAX=16384             
# Ballooning - set to 0 to disable, or a value less than VM_RAM_MAX to enable
VM_RAM_MIN=8192

############################
# Generate Autounattend.iso

genisoimage -iso-level 4 -udf -o "${ISO_PATH}/Autounattend.iso" -V AUTOUNATTEND "$(dirname "$1")"
UNATTEND_ISO="${ISO_PATH}/Autounattend.iso"

################
# Sanity checks 

for ISO in "$WIN_ISO" "$VIRTIO_ISO" "$UNATTEND_ISO"; do
  if [ ! -f "$ISO" ]; then
    echo "Missing ISO: $ISO"
    exit 1
  fi
done

############
# Create VM

# Allocate next available VMID
NEXTID=$(pvesh get /cluster/nextid)
VMNAME="Win11Auto${NEXTID}"

echo "Creating VM $VMNAME (ID: $NEXTID)..."

# Create base VM
qm create "$NEXTID" \
  --name "$VMNAME" \
  --machine q35 \
  --cores "$VM_CORES" \
  --sockets 1 \
  --memory "$VM_RAM_MAX" \
  --cpu host \
  --bios ovmf \
  --ostype win11 \
  --scsihw virtio-scsi-single

# Add EFI vars & TPM2
qm set "$NEXTID" --efidisk0 "${DISK_STORE}:1,efitype=4m,pre-enrolled-keys=1"
qm set "$NEXTID" --tpmstate0 "${DISK_STORE}:1,version=v2.0"

# System Disk
qm set "$NEXTID" --scsi0 "${DISK_STORE}:${VM_DISK_SIZE}",ssd=1
qm set "$NEXTID" --boot order=scsi0

# Network
qm set "$NEXTID" --net0 virtio,bridge="$BRIDGE"

# Display + QEMU Guest Agent
qm set "$NEXTID" --vga qxl
qm set "$NEXTID" --agent enabled=1

# Attach ISOs
qm set "$NEXTID" --ide0 "local:iso/$(basename "$VIRTIO_ISO"),media=cdrom"
qm set "$NEXTID" --ide1 "local:iso/$(basename "$UNATTEND_ISO"),media=cdrom"
qm set "$NEXTID" --ide2 "local:iso/$(basename "$WIN_ISO"),media=cdrom"

# Ballooning (optional)
if [[ "$VM_RAM_MIN" -gt 0 && "$VM_RAM_MIN" -lt "$VM_RAM_MAX" ]]; then
  echo "Enabling memory ballooning: min=${VM_RAM_MIN}MB max=${VM_RAM_MAX}MB"
  qm set "$NEXTID" --balloon "$VM_RAM_MIN"
else
  echo "Ballooning disabled"
  qm set "$NEXTID" --balloon 0
fi

qm set "$NEXTID" --boot 'order=scsi0;ide2'

echo "VM created successfully!"
echo "   VMID:  $NEXTID"
echo "   Name:  $VMNAME"
echo "   Console:  qm terminal $NEXTID  (or use the web UI)"

