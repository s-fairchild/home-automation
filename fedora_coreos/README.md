#

### Purpose

Deploy a self hosted Fedora CoreOS server to serve as
  * Motion camera server
    * Records rtsp streams to local raid
  * v4l2rtspserver
    * Provides rtsp stream for a local camera. This allows remote viewing via an rtsp client app, and recording with `motion`
  * Pihole
    * Sinkhole/Ad blocking DNS server
  * Unbound recursive DNS server
    * Upstream DNS for pihole
    * Note: Other upstream DNS servers such as Google's may be used if unbound causes too much latency
  * Emby/Plex media server
  * Graylog logging server
    * Log collection and visualization
    * Requires:
      * MongoDB
      * Elasticsearch 7.10.2
  * Local beat metric shippers
  * OpenVPN/Wireguard
    * Remote network access, mainly for DNS and Cameras
  * nginx reverse proxy server (in progress)
    * Provide endpoints for all web based applications via port 80/443
  * Gollum git backed wiki
    * Notes
  * git server
    * Used for obsidian git backing

### Files and Directories

1. `kore_common.bu`
    * Primary butane file containing all common configurations across environments
1. `kore_libvirt.bu`
    * Configuration for libvirt vm
1. `kore_btrfs_raid10.bu`
    * btrfs raid configuration used in bare metal production deployment
1. `kore_md_raid5.bu`
    * Linux software md raid config
1. `kore_production.bu`
    * Used to make an easy selection from hardware butane configs
    * Also used to hardcode UUID for filesystem reuse
1. `files/`
    * Directory containing all files used by butane to embed in ignition file for deployed system use
1. `isos/`
    * Directory containing custom created modified iso images with embedded ignition files
1. `scripts/`
    * Directory contains helper scripts for deploying/testing

#### Required Files and Directories not in source control
1. `fedora_coreos/files/container_secrets.tar.gz`
    * gzipped tar archive Contains podman secret files
    * These are loaded into the ignition, `create_podman_secrets.sh` runs on first boot creating the podman secrets
    * **All files in the archive must have the `.secret` file extension to be created**
    * Once the secrets are created all files are shredded
    * Example of archive contents:
      * ```bash
        [steven@r10 home-automation]$ tar tf fedora_coreos/files/container_secrets.tar.gz
        container_secrets/
        container_secrets/graylog.secret
        container_secrets/graylog_root_password_sha2.secret
        container_secrets/motion_camera1.secret
        container_secrets/motion_camera2.secret
        container_secrets/motion_camera3.secret
        container_secrets/pihole.secret
        container_secrets/plex.secret.secret
        container_secrets/v4l2rtspserver.secret
        container_secrets/v4l2rtspserver_camera1_url.secret
        container_secrets/v4l2rtspserver_camera2_url.secret
        container_secrets/v4l2rtspserver_camera3_url.secret
        ```
2. `fedora_coreos/files/luks_keys/data.key`
    * Required for encrypting `data` drive. Only configured in `kore_md_raid5.bu`.
    * Butane specification is unclear as to whether luks drives can be reused, it appears they cannot
    * Useful links
      *  [Red Hat Encrypting block devices using LUKS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/security_hardening/encrypting-block-devices-using-luks_security-hardening)
      * [Red Hat Luks Guide](https://www.redhat.com/sysadmin/disk-encryption-luks)
3. `fedora_coreos/files/graylog/.env`
   * Graylog `.env` configuration file
   * [Graylog Docker Documentation](https://go2docs.graylog.org/5-0/downloading_and_installing_graylog/docker_installation.htm)
4. `fedora_coreos/files/openvpn/keys/`
    * files: `ca.crt,ca.key,dh.pem,kore.crt,kore.key`
    * openvpn files
5. `fedora_coreos/isos`
    * ISO files created by `create_custom_iso.sh` are placed here

### How to use this repository

1. Test in libvirt vm
    * Testing configuration in a libvirt vm
      ```bash
      # Download the latest .qcow2 image
      # If you aren't using the latest image, fcos will reboot and update shortly after booting
      make libvirt-update
      # Start the libvirt vm
      # Open virt-manager and find the ip address of the VM above the log in prompt for ssh
      make libvirt-start
      ```
1. Deploy to bare metal with iso
    * Production bare metal iso creation
      ```bash
      # Download latest iso image
      podman run --security-opt label=disable --pull=always --rm -v .:/data -w /data \
        quay.io/coreos/coreos-installer:release download -s stable -p metal -f iso

      # OR Use provided shell script
      ./scripts/create_custom_iso.sh -g
      Downloading Fedora CoreOS stable x86_64 metal image (iso) and signature
      Read disk 19.9 MiB/733.0 MiB (2%)
      Read disk 39.6 MiB/733.0 MiB (5%)
      Read disk 60.5 MiB/733.0 MiB (8%)
      Read disk 80.8 MiB/733.0 MiB (11%)
      Read disk 101.3 MiB/733.0 MiB (13%)
      Read disk 121.5 MiB/733.0 MiB (16%)
      Read disk 142.1 MiB/733.0 MiB (19%)
      Read disk 162.6 MiB/733.0 MiB (22%)
      Read disk 183.8 MiB/733.0 MiB (25%)
      Read disk 204.2 MiB/733.0 MiB (27%)
      Read disk 220.7 MiB/733.0 MiB (30%)
      Read disk 241.1 MiB/733.0 MiB (32%)
      Read disk 260.9 MiB/733.0 MiB (35%)
      Read disk 281.4 MiB/733.0 MiB (38%)
      Read disk 301.7 MiB/733.0 MiB (41%)
      Read disk 322.9 MiB/733.0 MiB (44%)
      Read disk 342.1 MiB/733.0 MiB (46%)
      Read disk 362.3 MiB/733.0 MiB (49%)
      Read disk 382.7 MiB/733.0 MiB (52%)
      Read disk 403.0 MiB/733.0 MiB (54%)
      Read disk 419.2 MiB/733.0 MiB (57%)
      Read disk 440.5 MiB/733.0 MiB (60%)
      Read disk 461.8 MiB/733.0 MiB (63%)
      Read disk 483.3 MiB/733.0 MiB (65%)
      Read disk 504.8 MiB/733.0 MiB (68%)
      Read disk 521.9 MiB/733.0 MiB (71%)
      Read disk 543.0 MiB/733.0 MiB (74%)
      Read disk 564.1 MiB/733.0 MiB (76%)
      Read disk 584.4 MiB/733.0 MiB (79%)
      Read disk 605.2 MiB/733.0 MiB (82%)
      Read disk 625.6 MiB/733.0 MiB (85%)
      Read disk 641.6 MiB/733.0 MiB (87%)
      Read disk 662.7 MiB/733.0 MiB (90%)
      Read disk 683.2 MiB/733.0 MiB (93%)
      Read disk 703.0 MiB/733.0 MiB (95%)
      Read disk 724.1 MiB/733.0 MiB (98%)
      Read disk 733.0 MiB/733.0 MiB (100%)
      Read disk 733.0 MiB/733.0 MiB (100%)
      gpg: Signature made Mon Jan  9 20:14:02 2023 UTC
      gpg:                using RSA key ACB5EE4E831C74BB7C168D27F55AD3FB5323552A
      gpg: checking the trustdb
      gpg: marginals needed: 3  completes needed: 1  trust model: pgp
      gpg: depth: 0  valid:   4  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 4u
      gpg: Good signature from "Fedora (37) <fedora-37-primary@fedoraproject.org>" [ultimate]
      ./fedora-coreos-37.20221225.3.0-live.x86_64.iso

      # Move downloaded iso file to isos/
      # Example filename, your's will be a newer version
      mv ./fedora-coreos-37.20221225.3.0-live.x86_64.iso isos/

      # This generates a new ignition file and creates a new iso file from the default
      ./scripts/create_custom_iso.sh -i isos/fedora-coreos-37.20221225.3.0-live.x86_64.iso -d /dev/nvme0n1

      # A new created custom ISO file should exist with custom_date_ prefixed
      ls -l isos/custom_2023-01-25_fedora-coreos-37.20221225.3.0-live.x86_64.iso

      # Wipe destination USB drive
      wipefs -a /dev/sdX

      # Write the image to your installation media previously wiped
      sudo dd if=isos/custom_2023-01-25_fedora-coreos-37.20221225.3.0-live.x86_64.iso of=/dev/sdc status=progress bs=1M

      # Sync block devices
      sudo sync
      ```
1. Insert installation media into bare metal server and boot to it
    * Server will boot once into the live installer image
    * Once the installer image has written to the destination device
    * Note: **REMOVE THE INSTALLATION MEDIA** to prevent an install loop

### Modify git repositories

1. See `git-server-init.sh` usage
```bash
[steven@r10 fedora_coreos]$ files/bin/git-server-init.sh -h
USAGE:
    ./files/bin/git-server-init.sh -d </var/git/repo1>

ARGS:
    -d          Comma seperate list of git repository directories
    -h          This help message

EXAMPLES:
    ./files/bin/git-server-init.sh -d /var/git/repo1

    Multiple repos can be passed with commas seperating directories

    ./files/bin/git-server-init.sh -d /var/git/repo1,/var/git/repo2,/var/git/repo3
```
2. Modify `git-server-init` systemd unit file `ExecStart` line
   1. Add more repositories to create and init
```bash
    - name: git-server-init.service
      enabled: true
      contents: |
        [Unit]
        Description=Initializes bare git repositories to serve as remote repositories
        After=network-online.target
        Wants=network-online.target

        [Service]
        User=git
        Group=git
        WorkingDirectory=/var/data/git
        Type=simple
        ExecStart=/usr/local/bin/git-server-init.sh -d /var/data/git/obsidian.git

        [Install]
        WantedBy=multi-user.target
```
3. How to use fresh repository
```bash
# Add remote origin
git remote add origin git@kore:obsidian.git
# Create empty commit
git commit --allow-empty -m "Empty-Commit"
# Push to remote repository on kore
git push origin main
```
4. How to clone existing repository
```bash
git clone git@kore:obsidian.git
cd obsidian
git status
```

### References

1. [Fedora CoreOS Documentation](https://docs.fedoraproject.org/en-US/fedora-coreos/)

1. `create_custom_iso.sh` usage
    ```bash
    USAGE:
    ./scripts/create_custom_iso.sh -i <ISO_FILE> -d <SERVER_BOOT_DRIVE>

    ARGS:
        -i          ISO file downloaded with coreos-installer
        -d          Destination device file name to install Fedora CoreOS to when booting custom ISO image
        -h          This help message

    EXAMPLES:
        ./scripts/create_custom_iso.sh -i isos/fedora-coreos-37.20221106.3.0-live.x86_64.iso -d /dev/nvme0n1
    ```
1. Broadcom LSI Firmware
   - [Broadcom flashing guide](https://www.broadcom.com/support/knowledgebase/1211161501344/flashing-firmware-and-bios-on-lsi-sas-hbas)
