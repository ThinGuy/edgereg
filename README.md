### Note:
This is a fork of [3pings/pwp-edgereg-app](https://github.com/3pings/pwp-edgereg-app), cosmetic changes only (colors, allow for bigger images, etc) for customer demo using spectro cloud and palette.

# Getting Started

Tested on Ubuntu 22.04

### TL;DR

If LXD is intialized on your machine, use [lxd-edgereg.sh](https://raw.githubusercontent.com/ThinGuy/edgereg/main/lxd-edgereg.sh) to automate the installation and execute in a LXD machine container.


## Installation (Ubuntu):

```bash
sudo apt update
sudp apt install nodejs npm git curl -yqf --auto-remove --purge
git clone https://github.com/ThinGuy/edgereg.git
cd ~/edgereg
npm update
npm install
npm run dev
```

### Local:

After doing the above steps, open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

### LXD: 

Get IP of container using:
```bash
lxc list ${NAME} -c4
```

Open http://*{LXD Container IP}*:3000 with your browser to see the result.

