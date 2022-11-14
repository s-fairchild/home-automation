#!/bin/bash
secrets=(
    v4l2rtspserver
    v4l2rtspserver_url
    pihole
    motion_camera1
    motion_camera2
    motion_camera3
    plex
)
secret_dir=/var/container_secrets

for s in ${secrets[@]}; do
    ds="${secret_dir}/${s}"
    if [ -f "$ds" ]; then
        if podman secret create "$s" "$ds"; then
            shred -zu "$ds"
        else
        exit 1
        fi
    fi
done
