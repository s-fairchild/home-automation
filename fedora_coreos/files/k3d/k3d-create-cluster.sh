#!/bin/bash -x
#
# Run post k3d install

main() {
    CLUSTER="${CLUSTER:-titan}"
    K3D_REGISTRY="${K3D_REGISTRY:-k3d-registry}"
    K3D_NETWORK="${K3D_NETWORK:-k3d}"
    K3D_CLUSTER_YAML="${K3D_CLUSTER_YAML:-/usr/local/etc/k3d/k3d-cluster.yaml}"
    
    # Run in a subshell to keep script shell from exiting
    if [[ ! -f /usr/local/bin/k3d ]]; then
        bash -c "/usr/local/bin/k3d-installer.sh || echo "failed to install k3d! Exiting" && exit 1"
    fi

    # A new bridge network must be created because the default podman network doesn't
    # provided dns
    if ! podman network exists "$K3D_NETWORK"; then
        podman network create "$K3D_NETWORK"
    fi

    # Using FCOS Butane links doesn't work for some reason
    setup_podman_socket

    # k3d looks for docker's default network named "bridge"
    # We must create the registry using our new network with dns
    # to host our registry
    if ! podman container exists "$K3D_REGISTRY"; then
        k3d registry create --verbose --default-network k3d -p 5000
    fi

    # Use registry currently doesn't work as a yaml config option
    if ! k3d cluster list | grep titan &> /dev/null; then
        if k3d cluster create --verbose --registry-use "$K3D_REGISTRY" -c "${K3D_CLUSTER_YAML}" "${CLUSTER}"; then
            label_nodes
            create_kubeconfig
            create_bashcompletion
        fi
    else
        echo -e "Aborting... ${CLUSTER} found.\nIs there another ${CLUSTER} present?"
    fi
          
}

# setup_podman_socket setups podman to cover docker's socket connection for k3d
# Note: this WILL NOT WORK Environment=DOCKER_HOST=unix:/run/podman/podman.sock
# k3d tries and fails to connect to that endpoint, but /var/run/docker.sock works
setup_podman_socket() {
    systemctl disable --now docker docker.socket 
    systemctl mask docker docker.socket
              
    local docker_sock="/var/run/docker.sock"
    local podman_sock="/run/podman/podman.sock"
    if [[ -f $docker_sock ]]; then
        rm -f /$docker_sock
    fi
    systemctl enable --now podman.socket
    systemctl restart podman.socket
    ln -s "${podman_sock}" "$docker_sock"
}

# shellcheck disable=SC2120
label_nodes() {
    node_prefix="${1:-k3d-$CLUSTER-agent}"
    for i in {0..2}; do
	    podman exec -it "k3d-${CLUSTER}-server-0" kubectl label "node/${node_prefix}-${i}" node-role.kubernetes.io/worker=true
    done
}

create_bashcompletion() {
    local bash_k3d=/etc/bash_completion.d/k3d
    if [ ! -f $bash_k3d ]; then
        k3d completion bash > "${bash_k3d}"
    fi
}

create_kubeconfig() {
    kubeconfig="$HOME/.kube"
    if [[ ! -d "$kubeconfig" ]]; then
        mkdir "$kubeconfig"
    fi
    kubeconfig+="/config"
    k3d kubeconfig get titan > "$kubeconfig"

    echo "kubeconfig located at ${kubeconfig}"
}

main "$@"