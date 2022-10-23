#!/bin/bash -x

IGNITION_CONFIG="$HOME/src/github/pi-automation/fedora_coreos/kore_libvirt.ign"
IGNITION_FILE="$1"
IGNITION_CONFIG="/var/lib/libvirt/filesystems/$IGNITION_FILE"
IMAGE="/var/lib/libvirt/images/pool/fedora-coreos-36.20221001.3.0-qemu.x86_64.qcow2"
# IMAGE="/home/steven/.local/share/libvirt/images/fedora-coreos-36.20221001.3.0-qemu.x86_64.qcow2"
VM_NAME="fcos-test-01"
VCPUS="4"
RAM_MB="4096"
STREAM="stable"
DISK_GB="10"
RAID_DISK_GB="10"

sudo cp "$IGNITION_FILE" "$IGNITION_CONFIG"
sudo chcon --verbose --type svirt_home_t "$IGNITION_CONFIG"
chcon --verbose --type virt_image_t "$IMAGE"
sudo chown qemu: "$IGNITION_CONFIG"
sudo chown qemu: "$IMAGE"

# --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis \
virt-install --connect="qemu:///system" --name="${VM_NAME}" --vcpus="${VCPUS}" --memory="${RAM_MB}" \
    --os-variant="fedora-coreos-$STREAM" --import --graphics=none \
    --disk="size=${DISK_GB},backing_store=${IMAGE}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --disk="size=${RAID_DISK_GB}" \
    --network network=default \
    --boot menu=on,useserial=on \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"

# virsh attach-device "${VM_NAME}" --file cam_usb.xml --current

sudo virsh destroy fcos-test-01 && sudo virsh undefine --remove-all-storage fcos-test-01
