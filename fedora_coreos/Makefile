ONESHELL:
SHELL = /bin/bash

common:
	butane -s -d files/ -p kore_common.bu > files/ignitions/kore_common.ign

libvirt: common
	butane -s -d files/ -p kore_libvirt.bu > kore_libvirt.ign

start-libvirt: libvirt
	./launch_fcos_libvirt.sh kore_libvirt.ign


production: common
	# butane -s -d files/ -p kore_md_raid5.bu > files/ignitions/kore_md_raid5.ign && \
	butane -s -d files/ -p kore_btrfs_raid10.bu > files/ignitions/kore_btrfs_raid10.ign && \
	butane -s -d files/ -p kore_production.bu > files/ignitions/kore_production.ign

wireguard-qr-code:
	qrencode -t ansiutf8 -r wireguard/client/client1.conf
