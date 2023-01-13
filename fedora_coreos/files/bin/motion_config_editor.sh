#!/bin/bash
#
# Init script for motionplus container
# Replaces placeholder text in configuration files with podman secrets

set -o nounset \
    -o errexit

main() {
    tmp_dir="/mnt/motionplus"
    if [ ! -d "$tmp_dir" ]; then
        abort "${tmp_dir} not found"
    fi

    dest_conf="/usr/local/etc/motionplus"
    pushd "$tmp_dir"
    cp ./*.conf "${dest_conf}/" || abort "failed to copy ${tmp_dir}/*.conf to ${dest_conf}/"
    popd

    secrets=(
        "$motion_camera1"
        "$motion_camera2"
        "$motion_camera3"
    )

    url_secrets=(
        "$v4l2rtspserver_camera1_url"
        "$v4l2rtspserver_camera2_url"
        "$v4l2rtspserver_camera3_url"
    )

    i=1
    for s in ${secrets[@]}; do
        if ! sed -i "s/PLACEHOLDER/${s}/" "${dest_conf}/camera${i}.conf"; then
            abort "Failed to replace placeholder"
        fi
        ((i++))
    done
    unset s

    i=1
    for s in ${url_secrets[@]}; do
        if ! sed -i "s/URI/${s}/" "${dest_conf}/camera${i}.conf"; then
            abort "Failed to replace URI placeholder"
        fi
        ((i++))
    done

    unset secrets url_secrets

    if [[ $1 == "--" ]]; then
        shift
        echo "Executing: $*"
	    "$@"
    fi
}

abort() {
    echo "${1}, Aborting."
    exit 1
}

main "$@"
