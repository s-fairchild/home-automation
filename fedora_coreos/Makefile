ONESHELL:
SHELL = /bin/bash

common:
	butane -s -d files/ -p kore_common.bu > files/ignitions/kore_common.ign

libvirt: common
	butane -s -d files/ -p kore_libvirt.bu > kore_libvirt.ign

start-libvirt: libvirt
	./launch_fcos_libvirt.sh kore_libvirt.ign

production: common
	butane -s -d files/ -p kore_production.bu > files/ignitions/kore_production.ign
