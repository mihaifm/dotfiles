#!/usr/bin/env bash

set -euo pipefail

if [[ -n "$SUDO_USER" ]]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

#############
# Config area

CORES="${CORES:-2}"
MEMORY_MB="${MEMORY_MB:-2048}"
DISK_SIZE_GB="${DISK_SIZE_GB:-20}"

CI_USER="${CI_USER:-debian}"
SSH_PUBKEY_FILE="${SSH_PUBKEY_FILE:-${USER_HOME}/.ssh/trixie.pub}"

# allocate next available VMID
VMID=$(pvesh get /cluster/nextid)
VMNAME="Trixie${VMID}"

STORAGE="${STORAGE:-local-lvm}"
CI_STORAGE="${CI_STORAGE:-local-lvm}"
SNIPPET_STORAGE="${SNIPPET_STORAGE:-local}"

BRIDGE="${BRIDGE:-vmbr0}"
IPCONFIG0="${IPCONFIG0:-ip=dhcp}"

VMHOSTNAME="${VMHOSTNAME:-trixie${VMID}}"
TIMEZONE="${TIMEZONE:-UTC}"

ALLOW_SSH_PASSWORD="${ALLOW_SSH_PASSWORD:-0}"
# only used if ALLOW_SSH_PASSWORD=1
CI_PASSWORD="${CI_PASSWORD:-}"

IMAGE_NAME=debian-13-genericcloud-amd64.qcow2
IMAGE_URL="${IMAGE_URL:-https://cloud.debian.org/images/cloud/trixie/latest/${IMAGE_NAME}}"
IMAGE_CACHE_DIR="/var/lib/vz/template/cloud"
CACHED_IMAGE_PATH="${IMAGE_CACHE_DIR}/${IMAGE_NAME}"

SNIP_DIR="/var/lib/vz/snippets"
SNIP_NAME="trixie-${VMID}.yaml"

####################
# Validation checks

if [[ ! -f "$SSH_PUBKEY_FILE" ]]; then
  echo "ERROR: Public key not found: $SSH_PUBKEY_FILE" >&2
  echo "Create one with: ssh-keygen -t ed25519 -f ~/.ssh/trixie.key" >&2
  exit 1
fi

# read key content (single line)
SSH_KEY="$(cat "$SSH_PUBKEY_FILE" | tr -d '\n')"

# refuse to create if VM exists
if qm status "$VMID" >/dev/null 2>&1; then
  echo "ERROR: VMID $VMID already exists." >&2
  exit 1
fi

#######################
# Download cloud image

mkdir -p "$IMAGE_CACHE_DIR"

if [[ ! -f "$CACHED_IMAGE_PATH" ]]; then
  echo "Cloud image not found, downloading..."
  curl -L --fail -o "$CACHED_IMAGE_PATH" "$IMAGE_URL"
else
  echo "Using cached cloud image: $CACHED_IMAGE_PATH"
fi

IMAGE_PATH="$CACHED_IMAGE_PATH"

############
# Create VM

echo "Creating VM $VMID"
qm create "$VMID" \
  --name "$VMNAME" \
  --memory "$MEMORY_MB" \
  --cores "$CORES" \
  --cpu host \
  --net0 "virtio,bridge=${BRIDGE}" \
  --scsihw virtio-scsi-pci \
  --agent enabled=1 \

echo "Importing disk to $STORAGE ..."
qm importdisk "$VMID" "$IMAGE_PATH" "$STORAGE"
qm set "$VMID" --scsi0 "${STORAGE}:vm-${VMID}-disk-0"
qm resize "$VMID" scsi0 "${DISK_SIZE_GB}G"

echo "Adding Cloud-Init drive"
qm set "$VMID" --ide2 "${CI_STORAGE}:cloudinit"
qm set "$VMID" --boot order=scsi0
qm set "$VMID" --ipconfig0 "$IPCONFIG0"

echo "Writing cloud-init snippet"
mkdir -p "$SNIP_DIR"
SNIP_PATH="${SNIP_DIR}/${SNIP_NAME}"

if [[ "$ALLOW_SSH_PASSWORD" == "1" ]]; then
  if [[ -z "$CI_PASSWORD" ]]; then
    echo "ERROR: ALLOW_SSH_PASSWORD=1 requires CI_PASSWORD to be set." >&2
    exit 1
  fi

  cat > "$SNIP_PATH" <<EOF
#cloud-config
hostname: ${VMHOSTNAME}
timezone: ${TIMEZONE}
manage_etc_hosts: true

ssh_pwauth: true
chpasswd:
  list: |
    ${CI_USER}:${CI_PASSWORD}
  expire: false

users:
  - name: ${CI_USER}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: [sudo]
    lock_passwd: false
    ssh_authorized_keys:
      - ${SSH_KEY}

package_update: true
package_upgrade: false
packages:
  - qemu-guest-agent

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF

else
  cat > "$SNIP_PATH" <<EOF
#cloud-config
hostname: ${VMHOSTNAME}
timezone: ${TIMEZONE}
manage_etc_hosts: true

ssh_pwauth: false

users:
  - name: ${CI_USER}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: [sudo]
    lock_passwd: true
    ssh_authorized_keys:
      - ${SSH_KEY}

package_update: true
package_upgrade: false
packages:
  - qemu-guest-agent

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF
fi

echo "Attaching snippet to VM"
qm set "$VMID" --cicustom "user=${SNIPPET_STORAGE}:snippets/${SNIP_NAME}"
qm set "$VMID" --ciuser "$CI_USER"

echo "Regenerating cloud-init data"
qm cloudinit update "$VMID"

echo "Starting VM"
qm start "$VMID"

echo "VM started successfully!"
