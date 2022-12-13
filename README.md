## Shortcut

If LXD is intialized on your machine, use [this gist](https://gist.githubusercontent.com/ThinGuy/78dbc01dc7056640c3000aebf1bc5c72/raw/0fa3006efc4a735a5bb61a7ae0320dc610352f26/lxd-edgereg.sh) to run in a LXD machine container.

## Getting Started

Tested on Ubuntu 22.04

From an Ubuntu 22.04 instance:

```bash
sudo apt update
sudp apt install nodejs npm git curl -yqf --auto-remove --purge
git clone https://github.com/ThinGuy/edgereg.git
cd ~/edgereg
npm update
npm install
npm run dev
```

###Local Installation:

After doing the above steps, open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

###LXD Installation: 

Get IP of container using:
```bash
lxc list ${NAME} -c4
```

Open http://<LXD Container IP>:3000 with your browser to see the result.

