# Policies

```bash
allow-host-ipv6 (active)
  priority: -15000
  target: CONTINUE
  ingress-zones: ANY
  egress-zones: HOST
  services: 
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
        rule family="ipv6" icmp-type name="neighbour-advertisement" accept
        rule family="ipv6" icmp-type name="neighbour-solicitation" accept
        rule family="ipv6" icmp-type name="router-advertisement" accept
        rule family="ipv6" icmp-type name="redirect" accept

fw-host (active)
  priority: -1
  target: CONTINUE
  ingress-zones: internal
  egress-zones: HOST
  services: http https ssh
  ports: 53/udp 53/tcp 80/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

router (active)
  priority: -1
  target: CONTINUE
  ingress-zones: internal
  egress-zones: external
  services: http https
  ports: 53/tcp 53/udp 80/tcp 443/tcp 123/udp 993/tcp 993/udp 995/udp 995/tcp 1025-65535/udp 1025-65535/tcp 22/tcp 443/
udp 89/tcp 465/tcp
  protocols: icmp
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

# Zones

```bash
block
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

dmz
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

drop
  target: DROP
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

external (active)
  target: DROP
  icmp-block-inversion: no
  interfaces: wan
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: yes
  forward-ports: 
        port=1194:proto=tcp:toport=1194:toaddr=10.8.0.1
        port=1194:proto=udp:toport=1194:toaddr=10.9.0.1
  source-ports: 
  icmp-blocks: 
  rich rules: 

home
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

internal (active)
  target: default
  icmp-block-inversion: no
  interfaces: br0 wlp1s0
  sources: 10.50.0.0/24 10.0.0.0/24 192.168.1.0/24
  services: dhcp ssh
  ports: 53/udp 53/tcp 80/tcp 443/tcp 8080/tcp 8554/udp 8554/tcp 8555/tcp 8555/udp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

nm-shared
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: icmp ipv6-icmp
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
        rule priority="32767" reject

public
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

restricted
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 10.88.0.2/32
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

work
  target: default
  icmp-block-inversion: no
  interfaces: 
  sources: 
  services: 
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```