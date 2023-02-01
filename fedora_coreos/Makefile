ONESHELL:
SHELL = /bin/bash

common:
	butane -s -d files/ -p kore_common.bu > files/ignitions/kore_common.ign

podman-default:
	 butane -s -p kore_podman_machine.bu > files/ignitions/kore_podman_simple.ign && \
	 butane -s -p kore_simple_podman_machine.bu > files/ignitions/kore_simple_podman_machine.bu

libvirt: common
	butane -s -d files/ -p kore_libvirt.bu > files/ignitions/kore_libvirt.ign

libvirt-update:
	sudo ./scripts/launch_fcos_libvirt.sh -d

libvirt-start: libvirt
	./scripts/launch_fcos_libvirt.sh -f files/ignitions/kore_libvirt.ign

production: common
	# butane -s -d files/ -p kore_md_raid5.bu > files/ignitions/kore_md_raid5.ign && \
	butane -s -d files/ -p kore_btrfs_raid10.bu > files/ignitions/kore_btrfs_raid10.ign && \
	butane -s -d files/ -p kore_production.bu > files/ignitions/kore_production.ign

install-compose:
	COMPOSE="files/bin/podman-compose" && \
	curl -o $$COMPOSE https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py && \
	chmod +x $$COMPOSE

install-compose-host:
	sudo curl -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py && \
	sudo chmod +x /usr/local/bin/podman-compose && \
	sudo dnf in python3-dotenv podman-plugins python3-dotenv+cli -y && \
	if podman-compose version; then \
		echo "Successfully installed podman-compose"; \
		else echo "failed to install podman-compose"; \
	fi
