#!/usr/bin/env bash

set -euo pipefail

###############
# Utility area

if [[ -n "$SUDO_USER" ]]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

die() { echo "ERROR: $*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 ||  die "Missing required command: $1"; }
need_cmd qm
need_cmd jq
need_cmd pvesh
need_cmd curl

##############
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

START_TIMEOUT="${START_TIMEOUT:-30}"
AGENT_TIMEOUT="${AGENT_TIMEOUT:-30}"
CLOUDINIT_TIMEOUT="${CLOUDINIT_TIMEOUT:-30}"
IP_TIMEOUT="${IP_TIMEOUT:-30}"
SLEEP_STEP="${SLEEP_STEP:-2}"

####################
# Validation checks

if [[ ! -f "$SSH_PUBKEY_FILE" ]]; then
  die "Public key not found: $SSH_PUBKEY_FILE"
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
    die "ALLOW_SSH_PASSWORD=1 requires CI_PASSWORD to be set"
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

echo "VM $VMID started successfully!"

#############################
# Wait for VM to come online

vm_is_running() {
  qm status "$VMID" 2>/dev/null | grep -q "status: running"
}

wait_until() {
  # wait_until <timeout_seconds> <command>
  local timeout="$1"; shift
  local start now
  start="$(date +%s)"
  while true; do
    if "$@"; then
      return 0
    fi
    now="$(date +%s)"
    if (( now - start >= timeout )); then
      return 1
    fi
    sleep "$SLEEP_STEP"
  done
}

agent_network_get_interfaces() {
  # prints JSON with network interfaces on success; returns nonzero if agent not ready
  qm guest cmd "$VMID" network-get-interfaces 2>/dev/null
}

cloudinit_done() {
  # checks guest cloud-init status
  qm guest exec "$VMID" -- bash -lc  'command -v cloud-init >/dev/null 2>&1 && cloud-init status --wait >/dev/null 2>&1' >/dev/null 2>&1
}

get_ipv4() {
  agent_network_get_interfaces | jq -r '
    [.[] | .["ip-addresses"][]?
      | select(.["ip-address-type"]=="ipv4")
      | .["ip-address"]
      | select(. != "127.0.0.1")
    ][0] // empty
  '
}

has_ipv4() {
  local ip
  ip="$(get_ipv4 || true)"
  [[ -n "$ip" ]]
}

echo "Waiting for VM $VMID to be running..."
wait_until "$START_TIMEOUT" vm_is_running || die "VM did not reach 'running' within ${START_TIMEOUT}s"

echo "Waiting for qemu-guest-agent to respond..."
wait_until "$AGENT_TIMEOUT" agent_network_get_interfaces >/dev/null || die "qemu-guest-agent not responsive within ${AGENT_TIMEOUT}s"

echo "Waiting for cloud-init to finish inside the guest..."
wait_until "$CLOUDINIT_TIMEOUT" cloudinit_done || die "cloud-init did not report completion within ${CLOUDINIT_TIMEOUT}s"

echo "Waiting for guest IPv4 address..."
wait_until "$IP_TIMEOUT" has_ipv4 || die "No non-loopback IPv4 address found within ${IP_TIMEOUT}s"

ip="$(get_ipv4)"
echo "VM $VMID has IP addres: $ip"

##################################
# Generate Ansible inventory file

mkdir -p "$USER_HOME/ansible"
inventory_file="$USER_HOME/ansible/inventory${VMID}.ini"

cat > "${inventory_file}" <<EOF
[debian_vms]
trixie${VMID} ansible_host=${ip} ansible_user=debian ansible_ssh_private_key_file=~/.ssh/trixie ansible_python_interpreter=/usr/bin/python3
EOF

echo "Inventory for VM $VMID written to: ${inventory_file}"

