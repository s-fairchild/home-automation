#!/bin/bash

main() {
    secret_archive=/var/container_secrets.tar
    secrets="$(basename $secret_archive | cut -d . -f 1)"
    tar xvf "$secret_archive" || abort "failed to extract ${secret_archive}"
    readarray -d '' secret_files < <(find "$secrets" -name "*.secret" -print0)

    for s in ${secret_files[@]}; do
        if [ -f "$s" ]; then
            if podman secret create "$(basename $s | cut -d . -f 1)" "$s"; then
                shred -zu "$s"
            else
                abort "$s not found, exiting..."
            fi
        fi
    done

    cleanup

    systemctl disable podman-secrets.service || abort "failed to disable podman-secrets.service"
}

cleanup() {
    if shred -zu "$secret_archive"; then
        echo "Successfully shredded ${secret_archive}"
    else
        echo "failed to shred ${secret_archive}"
    fi
    if rm -rf "$secrets"; then
        echo "Successfully deleted ${secrets}"
    else
        echo "failed to delete ${secrets}"
    fi
}

#######################################
# abort echos a message and exits with code 1
#######################################
abort() {
    echo "${1}, Aborting."
    exit 1
}

main
