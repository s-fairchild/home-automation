#!/bin/bash -x

main() {
    make production

    ISOS="isos"
    DEFAULT_ISO="fedora-coreos-36.20221014.3.1-live.x86_64.iso"
    DEVICE="/dev/nvme0n1"
    IGNITION="files/ignitions/kore_production.ign"
    # IGNITION_URL="https://10.50.0.10:8000/kore_production.ign"
    # POST_INSTALL_SCRIPT="files/bin/create_podman_secrets.sh"
    NEW_ISO="${ISOS}/custom_$(date +%F)_${DEFAULT_ISO}"

    check_remove_iso
    create_new_iso

}

create_new_iso() {
        # --post-install="${POST_INSTALL_SCRIPT}" \
        # --ignition-url="${IGNITION_URL}" \
    coreos-installer iso customize \
        --dest-device="${DEVICE}" \
        --dest-ignition "${IGNITION}" \
        --force \
        -o "${NEW_ISO}" "isos/${DEFAULT_ISO}"
}

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

download_latest_iso() {
    podman run --security-opt \
        label=disable \
        --pull=always \
        --rm \
        -v .:/data \
        -w /data \
        quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso
}


# wipe_install_device() {

    # if [[ -z $1 ]]; then
        # abort "Installation device wasn't provided. Exiting."
    # fi
    # install_device="$1"

    # read -n 1 -p "ALL DATA ON $install_device WILL BE REMOVED! Are you sure? [y/n]"
    # if [[ $REPLY =~ [^y$] ]]

# }

abort() {
    echo "$1"
    exit 1
}

main
