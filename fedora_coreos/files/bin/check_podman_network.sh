#!/bin/bash

main() {
    check_network "${1}"
}

check_network() {
    net="${1}"
    if ! podman network exists "${net}"; then
        podman network create "${net}"
    else
        echo "${net} already exists"
    fi
}

main "$1"