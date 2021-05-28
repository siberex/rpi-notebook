# Install Node.js from binaries

Install latest Node.js version (14, 16, etc.) from [official binaries](https://github.com/nodejs/help/wiki/Installation#how-to-install-nodejs-via-binary-archive-on-linux).

It is better because Raspbian packages are usually quite outdated.


    NODEVER=v14.17.0
    ARCH=$(uname -m)
    wget https://nodejs.org/dist/$NODEVER/node-$NODEVER-linux-$ARCH.tar.xz

    sudo mkdir -p /opt/nodejs
    sudo tar -xf node-$NODEVER-linux-$ARCH.tar.xz --directory=/opt/nodejs --strip-components=1 --no-same-owner

    rm node-$NODEVER-linux-$ARCH.tar.xz

    sudo update-alternatives --install "/usr/bin/node" "node" "/opt/nodejs/bin/node" 1
    sudo update-alternatives --install "/usr/bin/npm" "npm" "/opt/nodejs/bin/npm" 1


# Compile Node.js from source

1. Increase swap

    - [Ubuntu](./ubuntu_x64.md#enable-swap)
    
    - [Raspbian](./setup.md#increase-swap)

2.

```bash
sudo apt install -y python3 g++ make git 
sudo apt install -y python3-distutils

cd /tmp
git clone https://github.com/nodejs/node.git

cd node
git checkout v14.17.0
./configure

# Note: This will take A LOT of time to compile on Raspberry hardware
# Don’t forget to increase swap first!

# screen -S nodebuild
make -j4

sudo make install
```
