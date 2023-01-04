#!/bin/bash -x

main() {
    tmp_dir="/mnt/temp_config"
    if [ -n "$1" ] && [ -d "$1" ]; then
        tmp_dir="$1"
    elif [ ! -d "$1" ] && [ -n "$1" ]; then
        echo "$1 must be an existing directory"
        exit 1
    fi
    cp /mnt/motion/*.conf "$tmp_dir"

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
        if ! sed -i "s/PLACEHOLDER/$s/" "${tmp_dir}/camera${i}.conf"; then
            echo "Failed to replace placeholder"
            exit 1
        fi
        ((i++))
    done
    unset s

    i=1
    for s in ${url_secrets[@]}; do
        if ! sed -i "s/URI/$s/" "${tmp_dir}/camera${i}.conf"; then
            echo "Failed to replace URI placeholder"
            exit 1
        fi
        ((i++))
    done
}

#######################################
# abort echos a message and exits with code 1
#######################################
abort() {
    echo "${1}, Aborting."
    exit 1
}

main "$1"
