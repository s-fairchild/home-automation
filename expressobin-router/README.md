# Arch Linux Arm Router/RTSP Server Setup Playbooks

This repository hosts the playbooks to configure a freshly installed Arch Linux Arm Server.<br>
The node performs these functions:
1. `Firewalld` firewall
1. Network router and internet gateway
1. DHCPv4 server
1. [Pihole](https://github.com/pi-hole/pi-hole) DNS server
1. RTSP Security Camera server

### Playbooks
1. `expressobin-router/initial_setup-playbook.yml`
1. `expressobin-router/firewalld-playbook.yml`
    * Configure firewalld
    * Configure v4l2rtspserver
    * Configure pihole
    * Configure dhcpdv4
1. `expressobin-router/beats-playbook.yml`
    * Configure elastic beats

### Useful Resources
1. [Arch Linux Arm Expressobin setup](https://archlinuxarm.org/platforms/armv8/marvell/espressobin)
1. [Arch Linux Arm Forum](https://archlinuxarm.org/forum/)