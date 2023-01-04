#!/bin/bash

set -o nounset -o errexit

# TODO add getopts to use flags
main() {
    IMG_PATH="${IMG_PATH:-/var/lib/libvirt/images/pool}"
    if [[ ${DOWNLOAD_IMAGE:-false} == "true" ]]; then
        download_update_image "$IMG_PATH"
        exit 0
    fi
    echo "IGNITION_FILE location: ${IGNITION_FILE:?Ignition file must be provided. See ${0} -h for usage information.}"
    IGNITION_CONFIG="/var/lib/libvirt/filesystems/$(basename ${IGNITION_FILE})"
    latest_img="$(get_latest_image "$IMG_PATH")"
    IMAGE="${BACKING_STORAGE:-$latest_img}"
    
    # VM resources
    VM_NAME="fcos-test-01"
    VCPUS="4"
    RAM_MB="4096"
    STREAM="stable"
    DISK_GB="20"
    RAID_DISK_GB="10"

    set_permissions

    # --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis \
    # --boot menu=on,useserial=on \
    virt-install --connect="qemu:///system" --name="${VM_NAME}" --vcpus="${VCPUS}" --memory="${RAM_MB}" \
        --os-variant="fedora-coreos-$STREAM" \
        --import \
        --graphics=spice \
        --disk="size=${DISK_GB},backing_store=${IMAGE}" \
        --disk="size=${RAID_DISK_GB}" \
        --disk="size=${RAID_DISK_GB}" \
        --disk="size=${RAID_DISK_GB}" \
        --disk="size=${RAID_DISK_GB}" \
        --disk="size=${RAID_DISK_GB}" \
        --network network=default \
        --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}"

    # sudo virsh destroy fcos-test-01 && sudo virsh undefine --remove-all-storage fcos-test-01
}

set_permissions() {
    sudo cp "$IGNITION_FILE" "$IGNITION_CONFIG"
    sudo chcon --verbose --type svirt_home_t "$IGNITION_CONFIG"
    sudo chcon --verbose --type virt_image_t "$IMAGE"
    sudo chown qemu: "$IGNITION_CONFIG"
    sudo chown qemu: "$IMAGE"
}

get_latest_image() {
    local p="$1"
    local latest
    latest="$(sudo ls -lhtr ${p} | tail -n -1 | cut -d ' ' -f 10)"
    if [[ -z $latest ]]; then
        abort "failed to find latest fedora coreos image"
    fi
    echo "${p}/${latest}"
}

is_root() {
    if [[ ! $(id -u) -eq 0 ]]; then
        abort "${0} must be ran as root or with sudo"
    fi
}

download_update_image() {
    local stream="stable"
    coreos-installer download -s "${stream}" -p qemu -f qcow2.xz --decompress -C "${1:-./}"
}

#######################################
# abort echos a message and exits with code 1
#######################################
abort() {
    echo "${1}, Aborting."
    exit 1
}

usage() {
    echo -e "USAGE:
    ./${0} -f <IGNITION_FILE> [-d]

ARGS:
    -f          Ignition file for machine to use during bootstrap
    -d          Download the latest ISO image
    -h          This help message

EXAMPLES:
"

    exit "${1:-0}"
}

while getopts ":f:d:b:" o; do
    case "${o}" in
        f)
            IGNITION_FILE="${OPTARG}"
            ;;
        b)
            # User provided image. If BACKING_STORAGE is null, the latest image is searched for.
            BACKING_STORAGE="${OPTARG}"
            ;;
        d)
            IMG_PATH="${OPTARG}"   
            DOWNLOAD_IMAGE="true"
            ;;
        :)
            case "${OPTARG}" in
                d)
                    DOWNLOAD_IMAGE="true"
                    ;;
                *)
                    abort "required option for ${OPTARG} not found"
                    ;;
            esac
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z $* ]]; then
    usage 1
fi

main "$@"
