#!/bin/bash
#
# Creates Fedora CoreOS live installer image with embedded ignition file

set -o errexit -o nounset

main() {
    if [[ ! -d isos/ ]]; then
        mkdir isos/ || abort "failed to create isos/ directory"
    fi

<<<<<<< HEAD
    if [[ ${DOWNLOAD_ISO:-false} == "true" ]]; then
        download_latest_iso "${DOWNLOAD_LOCATION:-./}"
        exit 0
    fi

=======
>>>>>>> 70a782e (Update README folder structure)
    ORIG_ISO="${ORIG_ISO:?ISO File must be provided with -i. Use ./${0} -h for usage information.}"
    DEST_DEVICE="${DEST_DEVICE:?Destination device must be provided with -d. Use ./${0} -h for usage information.}"
    NEW_ISO="isos/custom_$(date +%F)_${ORIG_ISO}"
    make production
    IGNITION="files/ignitions/kore_production.ign"
    for f in "isos/$ORIG_ISO" "$IGNITION"; do
        if [[ ! -f $f ]]; then
            abort "${f} not found."
        fi
    done

    echo "Generating new bare metal ignition file"
    if [[ ! -f $IGNITION ]]; then
        abort "$IGNITION not found."
    fi

    check_remove_iso

    if create_new_iso; then
        echo -e "\nCreated new iso image: ${NEW_ISO}"
        echo -e "\nWrite image to installation media with:\n\tsudo dd if=${NEW_ISO} of=/dev/sdX status=progress bs=1M\n"
        echo -e "Note: replace /dev/sdX with the name of your drive\n"
    fi
}


#######################################
# create_new_iso embeds the ignition file into a custom iso
# Outputs:
#   Writes iso file to isos/ directory
#######################################
create_new_iso() {
        # --post-install="${POST_INSTALL_SCRIPT}" \
        # --ignition-url="${IGNITION_URL}" \
    coreos-installer iso customize \
        --dest-device="${DEST_DEVICE}" \
        --dest-ignition "${IGNITION}" \
        --force \
        -o "${NEW_ISO}" "isos/${ORIG_ISO}"
}

#######################################
# check_remove_iso checks for an existing custom iso file with the same name
# and deletes it if so
#######################################
check_remove_iso() {
    if [[ -f $NEW_ISO ]]; then
        echo "Deleting existing iso image ${NEW_ISO}"
        if rm "${NEW_ISO}"; then
            echo "Successfully deleted ${NEW_ISO}"
        else
            abort "Failed to delete ${NEW_ISO}"
        fi
    fi
}

#######################################
# download_latest_iso uses core-installer podman container to download the latest bare metal iso image
#######################################
download_latest_iso() {
    local dest="${1:-./}"
    if [[ ! -d "$dest" ]]; then
        echo "$dest not found"
        DOWNLOAD_LOCATION="./"
    fi

    podman run --security-opt \
        label=disable \
        --pull=newer \
        --rm \
        -v "${dest}":/data \
        -w /data \
        quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso
}

#######################################
# abort echos a message and exits with code 1
#######################################
abort() {
    echo "${1}, Aborting."
    exit 1
}

#######################################
# usage prints the script usage information and exits an exit code if provided
# if no exit code is provided, exit code is 0
#######################################
usage() {
    echo -e "USAGE:
    ./${0} -i <ISO_FILE> -d <SERVER_BOOT_DRIVE>

ARGS:
    -i          ISO file downloaded with coreos-installer
    -d          Destination device file name to install Fedora CoreOS to when booting custom ISO image
    -g          Download the latest ISO image
    -h          This help message

EXAMPLES:
    ./${0} -i isos/fedora-coreos-37.20221106.3.0-live.x86_64.iso -d /dev/nvme0n1
"
    exit "${1:-0}"
}

while getopts ":g:i:d:h" o; do
    case "${o}" in
    i)
        ORIG_ISO="${OPTARG}"
        ;;
    d)
        DEST_DEVICE="${OPTARG}"
        ;;
    g)
        DOWNLOAD_ISO="true"
        DOWNLOAD_LOCATION="${OPTARG}"
        ;;
    h)
        usage
        ;;
    :)
        case "${OPTARG}" in
        g)
            DOWNLOAD_ISO="true"
        ;;
        esac
        ;;
    *)
        usage 1
        ;;
    esac
done

if [[ -z $* ]]; then
    usage 1
fi

main

exit 0
