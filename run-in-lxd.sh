#!/bin/bash

### Change these variables to match your preferences

# This will be a secondary user to the default User of "ubuntu"
export ME=craigbender
# Launchpad ID to import keys
export LPID=craig-bender
# DNS Domain name
export DOM=craigbender.me
# Existing bridge or LXD managed bridge
export BRIDGE=br0
# Name to assign to LXD container and profile
export NAME=pwp

### Only change below this line if you know what you are doing

lxc 2>/dev/null profile create ${NAME}
lxc 2>/dev/null delete -f ${NAME}

cat <<EOF |sed -r 's/[ \t]+$//g'|lxc profile edit ${NAME}
config:
  boot.autostart: "true"
  linux.kernel_modules: ip_vs,ip_vs_rr,ip_vs_wrr,ip_vs_sh,ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter
  raw.lxc: |
    lxc.apparmor.profile=unconfined
    lxc.mount.auto=proc:rw sys:rw cgroup:rw
    lxc.cgroup.devices.allow=a
    lxc.cap.drop=
  security.nesting: "true"
  security.privileged: "true"
  user.network-config: |
    version: 2
    ethernets:
      eth0:
        dhcp4: false
        dhcp6: false
        accept-ra: false
        optional: true
        mtu: 1472
    bridges:
      ${BRIDGE}:
        interfaces: [eth0]
        mtu: 1472
        dhcp4: true
        dhcp4-overrides:
          use-dns: false
          use-hostname: false
          use-domains: false
          route-metric: 0
        dhcp6: true
        dhcp6-overrides:
          use-dns: false
          use-hostname: false
          use-domains: false
          route-metric: 0
        accept-ra: false
        optional: false
        nameservers:
          addresses:
           - 1.1.1.1
           - 1.0.0.1
           - '2606:4700:4700::1111'
           - '2606:4700:4700::1001'
          search:
           - ${DOM}
        parameters:
          priority: 0
          stp: false
  user.user-data: |
    #cloud-config
    timezone: America/Los_Angeles
    locale: en_US.UTF-8
    package_update: yes
    package_upgrade: yes
    final_message: 'EdgeReg Container completed in \$UPTIME'
    manage_etc_hosts: false
    manage_resolv_conf: true
    resolv_conf:
      nameservers: ['1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001']
      searchdomains:
        - ${DOM}
      domain: ${DOM}
      options:
        rotate: true
        timeout: 1
    groups:
      - ubuntu
      - ${ME}
      - power
    users:
      - name: ubuntu
        homedir: /home/ubuntu
        gecos: Default User
        groups: ubuntu, adm, dialout, cdrom, floppy, sudo, audio, dip, video, power, plugdev, netdev, lxd
        primary_group: ubuntu
        lock_passwd: false
        passwd: \$6$\rounds=4096\$ox6T7Xv0j9sYJhd7$VIw3A8RVAHAP/vfZFJFNOupES3IqL4M64TjHTKYNmCAiNzZN0I3hdLGYGj7ppFYU0Nzc6Wn7EgkyKzK.afkBB0
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_import_id:
          - lp:${LPID}
      - name: ${ME}
        homedir: /home/${ME}
        gecos: Demo User
        primary_group: ${ME}
        groups: ${ME}, adm, dialout, cdrom, floppy, sudo, audio, dip, video, power, plugdev, netdev, lxd
        lock_passwd: false
        passwd: \$6\$rounds=4096\$NdrYH9iwfbDJ.jmU$i1QFKBEM7XQeayVqav3TV8ckTybVmmouALeSiaquVyqPBn7fHaH1MPtT4oaVBRs7pfl5BvQu8AxgvUmrTxYfO0
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_import_id:
          - lp:${LPID}
    snap:
      commands:
        00: ['core', 'install']
        01: ['core18', 'install']
        02: ['core20', 'install']
        03: ['core22', 'install']
    apt:
      primary:
       - arches: [amd64]
         uri: 'http://us.archive.ubuntu.com/ubuntu'
      security:
       - arches: [amd64]
         uri: 'http://us.archive.ubuntu.com/ubuntu'
      sources_list: |
        deb [arch=amd64] \$PRIMARY \$RELEASE main universe restricted multiverse
        deb [arch=amd64] \$PRIMARY \$RELEASE-updates main universe restricted multiverse
        deb [arch=amd64] \$SECURITY \$RELEASE-security main universe restricted multiverse
        deb [arch=amd64] \$PRIMARY \$RELEASE-backports main universe restricted multiverse
      conf: |
        APT {
          Get {
            Assume-Yes True;
            Fix-Broken True;
          };
          Acquire {
            ForceIPv4 True;
          };
        };
    packages:
      - build-essential
      - curl
      - git
      - nodejs
      - npm
      - openssh-server
      - plocate
      - software-properties-common
      - unzip
      - vim
      - wget
      - zip
    ssh_pwauth: true
    ssh_authorized_keys:
      - ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBADviK4QkET0s1TxcPH0ezmdLcAtlyvsM1kN5mYkupzoHuscB5cw6rU6MoHVylwzj41/U2zJYFGoWLOCahyg/dfpNQBqep0OdxcDm3aBnswD+Vac49zmOo56cNOJeluPIiHyIF3ys6k3NEGW9sBdNFMVFs4RX8SurFvPTqMSoQoSJ4PQ8Q== ${ME}@canonical.com
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcHM9zZP5Ca00FKtNDLk+PXXKeHJjgzGhNoMxKGWUDxq46ei5J0Bwz5G0zya+H1KbDNowBO4Az0cXWV3Zyq+m3KRamQdGH6rmEH9M7v8+OMdD9biJhWVhEOXfB0tSyxTjoipRTkyLdGZRdZ+o0Af7OxNx21Eo84QDR2H+4cBLwFA8l7yFJrY8aR0dPsWMcMBEdTydH13LvMV/dII1J6Fppfi+eDOoy8HpnlAs3411QNgR1IQow3vqpynnkaH68oRi2Db0bOQC6EUe2mCRVqI5Ro4OgtS9JlZJZ8BxikkyxujapH9K3xZYl6HG4lq7WWYIme4uMM2xo8rLMwfWytyjNfWJfRmNsxtUGywBQdIipe2FE7F05nPClmb4U2B5rAJiNjTJNCnhiZMaaF1C8kVExf4ldarZMTBHfQAoDizHrn6m4VPpVKCMM4zuc177QxPPtHSDMpgt2KXegJfXaU3UW4xc0aH8yrCX+4QPe9yQQ464edGf5iLwonheUVXxf58v3yVCDS3b7CBKpgU0xOIcsx8IPYkWfHKlBwtpZR1JVV0LiW9ivXyJJgQLOUGVQ70FeVx+uLT+HuWLc4rVLmzHMBJhpS+cEMGBnOSu5IXYfK2n4v1MrQBMS13SA6NwxZ15mf5FKs0oxFFk3qERTQl9+FhzGjwHq9vojX0vXXyML8w== ${ME}@canonical.com
      - ssh-dss AAAAB3NzaC1kc3MAAACBAKjRfx8vqk3cjzRw/f0TEERFvmrqGu6SgmvuQ53qXUy20ZC553jcnXDXwQnXdvRAmjuBSJVfAcFbKreOJhkwP6/Tl47Mo5seYab9RZ3MRTMXr4bVgSous4m/lrLt4zpWxsbEISa7uqTaogPPUVSNReAiHzYcdWbh8f0luVCbyfb7AAAAFQDLxAZCcO07vZag4qYcUBsshX8YhQAAAIAdB08hFUQ2EHJrHGGGVovUGoo0r6YSy0YEtJ7sSeCSkFP2KTeOujA3uNaQDdxNHaoMc1sYb2OIZlQAsS63X4F36/GbGyVXVoSj9S5QCi74RF6cz+CHay1+UK1yjt/AsrweixccRp6/FKf9ZvEXx4f7+A/h8iGwdN7iHvG3ZesEeAAAAIB0Z7q1Id6cZEGn73AE/O9CJumnY8+HOk/KI+rkWZdDr7G5LR9HS8snhLg458GYVAMVWfEjx6acY+Xdn0Rx+l61WLFimG8lLOOUqqcDJbI1iJYy5MtIjDEKYEFlHAJBfnLQi//x3TJutZUxuLM//f2bvJWTeIMysdGh4/MuaJR7+w== craig.bender@canonical.com_work_pw_2020_dsa
      - ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACEPIilu+9J1BB4T/pJpvkKimj0xQLav0bIDMORuB7LiET62nX4Kv8gkJdAaks0yEhVlTcc6nLArnhHc7wDFC0Y4gESbJsdjpMNXtbbXf23B6LsXNPqV0LATu0gVpKHUzPfhNJz+UJSsICCB1wvlMMeaQZIFSgHilvKhA2sJnq+w/4mYA== craig.bender@canonical.com_work_pw_2020_ecdsa
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/lkMJv3uV76OmZCx07K56qIWpD3UnkVqXyqpM9abak craig.bender@canonical.com_work_pw_2020_ed25519
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCm6mabpLiOlFuA1/M814yyrWc7GO6TqNWXbrqgU1KpRnd4Pjz0hyR8+w99/qst+NfAQWK3LjPQXZYPdvwrD1LVYZg8d05ZDfhixUfMlZq/5tIXUVhNEbA9GUR3iV3sY/Jki0DQMr4JBjxVqxzNNtfYwLwtsY7Sf6jVPxQt2p+YxBn/+IF4RN4g9BS+yaIvkl9e1VR+khQH5j1wMulnKs9xQl6kPZ0iGL+dCHos2KMfHAx6dEFzkH2eGES9X+EBMXfnaxL7CJBragq5Qb7LGxQiIldYLHQTBUlRRc4H9Hr37dRTwk2aLFHhh9h4/tQOTsEXW2igPEyLb75znGsbinB9ob3bOYErkyQJUyeDyGsTI2xKeIEYHHOBtmeS+YvcYCbcXipgsB9liThQ6vyxO5eau4yjUfWI2Rbq+QAhEm1VIDi4ihskrjIqQehx34MfNW/mS0JyJFIv2v8fzf1dOidy7Hax4IX9wVdLqBBgVWPE6DXy9oFB4ajVg1PUcXI1OYBi/wPumF50zsarj5Zs7/hqsdXw2PHioM6XOGCc0kylZm6mtOI1PEAM4QxUZW/5kgJJIfdn+jQCygi3Q+tTdhWKLbJU92dUx4dlMkyROkreJ+U04TT3wjzZsBtaz9KdMSnknEROU+uK+imo2SpU7HOLTSahViCtiKkUfLjtJYKkaw== craig.bender@canonical.com_work_pw_2020_rsa
    bootcmd:
      - ['cloud-init-per', 'once', 'bc0', 'set', '-x']
      - ['cloud-init-per', 'once', 'bc1', 'export', 'DEBIAN_FRONTEND=noninteractive']
    runcmd:
      - set -x
      - export DEBIAN_FRONTEND=noninteractive
      - update-alternatives --set editor /usr/bin/vim.basic
      - su - \$(id -un 1000) --login -c 'https://github.com/ThinGuy/${NAME}-edgereg-app.git ~/edgereg'
      - su - \$(id -un 1000) --login -c 'cd ~/edgereg;npm update;npm install;npm run dev'
description: Palette Edge Registration Tool
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: ${BRIDGE}
    type: nic
  root:
    path: /
    pool: default
    size: 20GiB
    type: disk
EOF

lxc launch ubuntu-daily:j ${NAME} -p ${NAME} --console
