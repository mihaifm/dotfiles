#!/usr/bin/env bash

set -euo pipefail

print_usage() {
  cat <<'USAGE'
Usage: create_win11_vm.sh --xml <autounattend.xml> [options]

Required:
  --xml PATH          Path to Autounattend.xml

Optional:
  --iso PATH          Path to Windows ISO file (default: /var/lib/vz/template/iso/Win11_25H2_NoPrompt.iso)
  --cores N           CPU cores (default: 4)
  --disksize GB       Disk size in GB (default: 64)
  --maxram GB         Max RAM in GB (default: 16)
  --minram GB         Min RAM in GB for ballooning (0 disables; default: 8)
  --start             Start the VM after creation

Examples:
  ./create_win11_vm.sh --xml /path/to/Autounattend.xml \
                    --iso /var/lib/vz/template/iso/Win11_25H2_NoPrompt.iso \
                    --cores 6 --disksize 128 --maxram 24 --minram 12
USAGE
}

########################
# Default config values

DISK_STORE="local-lvm"
ISO_PATH="/var/lib/vz/template/iso"
WIN_ISO="${ISO_PATH}/Win11_25H2_NoPrompt.iso"
VIRTIO_ISO="${ISO_PATH}/virtio-win-0.1.285.iso"
VM_CORES=4
VM_DISK_SIZE=64
BRIDGE="vmbr0"
VM_RAM_MAX=$((16 * 1024))
VM_RAM_MIN=$((8 * 1024))
START_VM=false
XML_PATH=""

###################
# Helper functions

is_int() { [[ "$1" =~ ^[0-9]+$ ]]; }
gb_to_mb() { echo $(( $1 * 1024 )); }

##################
# Parse arguments

if [[ "$#" -eq 0 ]]; then
  print_usage
  exit 1
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --iso)
      WIN_ISO="$2"
      ISO_PATH="$(dirname "$2")"
      shift 2
      ;;
    --cores)
      is_int "$2" || { echo "Invalid value for --cores"; exit 2; }
      VM_CORES="$2"
      shift 2
      ;;
    --disksize)
      is_int "$2" || { echo "Invalid value for --disksize"; exit 2; }
      VM_DISK_SIZE="$2"
      shift 2
      ;;
    --maxram)
      is_int "$2" || { echo "Invalid value for --maxram"; exit 2; }
      VM_RAM_MAX="$(gb_to_mb "$2")"
      shift 2
      ;;
    --minram)
      is_int "$2" || { echo "Invalid value for --minram"; exit 2; }
      VM_RAM_MIN="$(gb_to_mb "$2")"
      shift 2
      ;;
    --xml)
      XML_PATH="$2"
      shift 2
      ;;
    --start)
      START_VM=true
      shift 1
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

#################
# Validate input

if [[ -z "$XML_PATH" ]]; then
  echo "Error: --xml parameter is required."
  print_usage
  exit 1
fi

if [[ ! -f "$XML_PATH" ]]; then
  echo "Error: Autounattend file not found: $XML_PATH"
  exit 1
fi

if (( VM_RAM_MIN > 0 && VM_RAM_MIN >= VM_RAM_MAX )); then
  echo "Error: --minram must be less than --maxram (or 0 to disable ballooning)."
  exit 1
fi

VIRTIO_ISO="${ISO_PATH}/$(basename "$VIRTIO_ISO")"

############################
# Generate Autounattend.iso

mkdir -p "$ISO_PATH"
UNATTEND_ISO="${ISO_PATH}/Autounattend.iso"
genisoimage -iso-level 4 -udf -o "$UNATTEND_ISO" -V AUTOUNATTEND "$(dirname "$XML_PATH")"

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
echo "   VMID:     $NEXTID"
echo "   Name:     $VMNAME"
echo "   ISO:      $(basename "$WIN_ISO")"
echo "   Disk:     ${VM_DISK_SIZE}G"
echo "   vCPU:     ${VM_CORES}"
echo "   RAM:      max ${VM_RAM_MAX} MB, min ${VM_RAM_MIN} MB"

if [[ "$START_VM" == true ]]; then
  echo "Starting VM $NEXTID..."
  qm start "$NEXTID"
  echo "VM started successfully!"
fi