VMNAME=win11-kvm
ISO_WIN=~/ISO/Win11_25H2_German_x64.iso
ISO_VIRTIO=/home/jonas/ISO/virtio-win-0.1.285.iso
DISK=~/vms/$VMNAME.qcow2

qemu-img create -f qcow2 "$DISK" 100G

sudo virt-install \
  --name "$VMNAME" \
  --memory 8192 --vcpus 4 \
  --cpu host-passthrough \
  --machine q35 \
  --os-variant win11 \
  --graphics spice \
  --video qxl \
  --controller type=scsi,model=virtio-scsi \
  --disk path="$DISK",bus=scsi,format=qcow2,cache=none,discard=unmap,detect-zeroes=unmap \
  --cdrom "$ISO_WIN" \
  --disk path="$ISO_VIRTIO",device=cdrom \
  --network network=default,model=virtio \
  --rng /dev/urandom \
  --tpm backend=emulator,model=tpm2 \
  --boot uefi
#!/usr/bin/env bash

set -euo pipefail

VMNAME=${VMNAME:-win11-kvm}
ISO_WIN=${ISO_WIN:-$HOME/ISO/Win11_25H2_German_x64.iso}
ISO_VIRTIO=${ISO_VIRTIO:-$HOME/ISO/virtio-win-0.1.285.iso}
DISK_DIR=${DISK_DIR:-$HOME/vms}
DISK_SIZE=${DISK_SIZE:-100G}
DISK="$DISK_DIR/$VMNAME.qcow2"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-disk)
      FORCE_DISK_RECREATE=true
      shift
      ;;
    --help|-h)
      cat <<EOF
Usage: $(basename "$0") [--force-disk]

Environment variables:
  VMNAME       Name of the virtual machine (default: win11-kvm)
  ISO_WIN      Path to the Windows installation ISO
  ISO_VIRTIO   Path to the VirtIO driver ISO
  DISK_DIR     Directory for the VM disk image (default: \$HOME/vms)
  DISK_SIZE    Disk size passed to qemu-img (default: 100G)
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

for cmd in qemu-img virt-install; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

if [[ ! -f "$ISO_WIN" ]]; then
  echo "Windows ISO not found at: $ISO_WIN" >&2
  exit 1
fi

if [[ ! -f "$ISO_VIRTIO" ]]; then
  echo "VirtIO ISO not found at: $ISO_VIRTIO" >&2
  exit 1
fi

mkdir -p "$DISK_DIR"

if [[ -f "$DISK" ]]; then
  if [[ "${FORCE_DISK_RECREATE:-false}" == true ]]; then
    rm -f "$DISK"
  else
    echo "Reusing existing disk: $DISK"
  fi
fi

if [[ ! -f "$DISK" ]]; then
  echo "Creating disk image at $DISK ($DISK_SIZE)"
  qemu-img create -f qcow2 "$DISK" "$DISK_SIZE"
fi

sudo virt-install \
  --name "$VMNAME" \
  --memory 8192 --vcpus 4 \
  --cpu host-passthrough \
  --machine q35 \
  --os-variant win11 \
  --graphics spice \
  --video qxl \
  --controller type=scsi,model=virtio-scsi \
  --disk path="$DISK",bus=scsi,format=qcow2,cache=none,discard=unmap,detect-zeroes=unmap \
  --cdrom "$ISO_WIN" \
  --disk path="$ISO_VIRTIO",device=cdrom \
  --network network=default,model=virtio \
  --rng /dev/urandom \
  --tpm backend=emulator,model=tpm2 \
  --boot uefi
