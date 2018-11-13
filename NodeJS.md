# Install NodeJS from binaries

Install latest Node JS version (10, 11, etc.) from official binaries.

It is better because Raspbian packages are usually quite outdated.


    NODEVER=v11.1.0
    wget https://nodejs.org/dist/$NODEVER/node-$NODEVER-linux-armv7l.tar.xz

    sudo mkdir -p /opt/nodejs
    sudo tar -xf node-$NODEVER-linux-armv7l.tar.xz --directory=/opt/nodejs --strip-components=1
    sudo chown -R root:root /opt/nodejs

    rm node-$NODEVER-linux-armv7l.tar.xz

    sudo update-alternatives --install "/usr/bin/node" "node" "/opt/nodejs/bin/node" 1
    sudo update-alternatives --install "/usr/bin/npm" "npm" "/opt/nodejs/bin/npm" 1
    
    