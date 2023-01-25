#!/bin/bash
#
# Init script to run before starting kibana podman container
# See for more information: https://www.elastic.co/guide/en/kibana/current/docker.html

main() {
    podman exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
}

main "$@"
