#!/bin/bash -x

set -o nounset -o errexit

# TODO add getopts to use flags
main() {
    POOL="${POOL:-nfspool}"
    IMG_PATH="${IMG_PATH:-/var/lib/libvirt/${POOL}/images}"
    if [[ ${DOWNLOAD_IMAGE:-false} == "true" ]]; then
        download_update_image "$IMG_PATH"
        exit 0
    fi
    echo "IGNITION_FILE location: ${IGNITION_FILE:?Ignition file must be provided. See ${0} -h for usage information.}"
    IGNITION_CONFIG="/var/lib/libvirt/filesystems/$(basename ${IGNITION_FILE})"
    # if [ "${BACKING_STORE:-false}" != "false" ]; then
    latest_img="$(get_latest_image "$IMG_PATH")"
    IMAGE="${BACKING_STORE:-$latest_img}"
    # fi
    
    VM_NAME="${VM_NAME:-fcos-test-01}"
    VCPUS="${VCPUS:-4}"
    RAM_MB="${RAM_MB:-10240}"
    STREAM="${STREAM:-stable}"
    DISK_GB="${DISK_GB:-20}"
    NETWORK="${NETWORK:-nat}"

    set_permissions

    virt-install --connect="qemu:///system" --name="${VM_NAME}" --vcpus="${VCPUS}" --memory="${RAM_MB}" \
        --os-variant="fedora-coreos-$STREAM" \
        --import \
        --graphics=spice \
        --disk="pool=${POOL},size=${DISK_GB},backing_store=${IMAGE},cache=writeback,sparse=yes" \
        --network "network=${NETWORK}" \
        --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}" \
        --check disk_size=off \
        --autostart \
        --noautoconsole

    # sudo virsh destroy fcos-test-01 && sudo virsh undefine --remove-all-storage fcos-test-01
}

create_storage_pool() {
    systemctl enable --now nfs-server
    exportfs -r
    virsh pool-define-as nfspool netfs --source-host localhost --source-path /var/data/nfspool/ --target /var/lib/libvirt/images/nfspool/
    virsh pool-autostart nfspool
}

set_permissions() {
    sudo cp "$IGNITION_FILE" "$IGNITION_CONFIG"
    # sudo chcon --verbose --type svirt_home_t "$IGNITION_CONFIG"
    # sudo chcon --verbose --type virt_image_t "$IMAGE"
    sudo chown qemu: "$IGNITION_CONFIG"
    sudo chown qemu: "$IMAGE"
    chown -R qemu: "${IMG_PATH}"
}

get_latest_image() {
    local pool="$1"
    local latest
    latest="$(sudo ls -ltr ${pool} | tail -n -1 | cut -d ' ' -f 10)"
    if [[ -z $latest ]]; then
        abort "failed to find latest fedora coreos image"
    fi
    echo "${pool}/${latest}"
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
    ./${0} -f <IGNITION_FILE> [-d] [-b] [-h]

ARGS:
    -f          Ignition file for machine to use during bootstrap
    -d          Download the latest .qcow2 libvirt image
    -b          Backing image
    -p          Pre existing storage pool
    -h          This help message

EXAMPLES:
"

    exit "${1:-0}"
}

while getopts ":f:d:b:p:" o; do
    case "${o}" in
        f)
            IGNITION_FILE="${OPTARG}"
            ;;
        b)
            # User provided image. If BACKING_STORAGE is null, the latest image is searched for.
            BACKING_STORE="${OPTARG}"
            ;;
        d)
            IMG_PATH="${OPTARG}"   
            DOWNLOAD_IMAGE="true"
            ;;
        p)
            POOL="${OPTARG}"
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
