#!/bin/bash
#
# Init script to run before starting kibana podman container
# See for more information: https://www.elastic.co/guide/en/kibana/current/docker.html

# podman run -it --rm -v /usr/local/etc/kibana.yml:/usr/share/kibana/config/kibana.yml:Z,U -v /var/data/kibana/data:/usr/share/kibana/data docker.elastic.co/kibana/kibana:8.6.0 bin/kibana-keystore add test_keystore_setting
# podman run -it --rm -v /usr/local/etc/kibana.yml:/usr/share/kibana/config/kibana.yml:Z,U -v /var/data/kibana/data:/usr/share/kibana/data docker.elastic.co/kibana/kibana:8.6.0 bin/kibana-keystore create
# podman run -it --rm -v /usr/local/etc/kibana.yml:/usr/share/kibana/config/kibana.yml:Z,U -v /var/data/kibana/data:/usr/share/kibana/data docker.elastic.co/kibana/kibana:8.6.0 bin/kibana-encryption-keys generate

main() {
    if [[ -f bin/kibana-keystore ]]; then
        bin/kibana-keystore create
    else
        abort "bin/kibana-keystore not found"
    fi
    if [[ -f bin/kibana-encryption-keys ]]; then
        bin/kibana-encryption-keys generate
    else
        abort "bin/kibana-encryption-keys not found"
    fi

    if [[ $1 == "--" ]]; then
        shift
        # Tell tini it's a subprocess to handle the resulting zombie process
        export TINI_SUBREAPER
        echo "Executing Entrypoint: $*"
	    "$@"
    fi
}

abort() {
    echo "${1}, Aborting."
    exit 1
}

main "$@"