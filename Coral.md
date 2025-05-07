# Coral Edge TPU

## Links

- https://github.com/google-coral/libedgetpu The Edge TPU Runtime (libedgetpu)
- https://github.com/google-coral/libcoral The Coral C++ library (libcoral)
- https://github.com/google-coral/pycoral The Coral Python library (PyCoral)
- https://github.com/google-coral/test_data Various models and other testing data
- https://github.com/google/gasket-driver Coral Gasket Driver (allows usage of the Coral EdgeTPU on Linux systems)

## How to configure the Google Coral Edge TPU on the Raspberry Pi 5

Add to the `/boot/firmware/config.txt`:

```conf
# Set 4k page size instead of 16k
kernel=kernel8.img

# Enable PCIe at gen 3 speed
dtparam=pciex1
dtparam=pciex1_gen=3

# Enable Pineboards Hat Ai, if needed:
dtoverlay=pineboards-hat-ai
```


## [libedgetpu](https://github.com/google-coral/libedgetpu)

libedgetpu — userspace level runtime driver for Coral.ai devices for Linux.

[Install with apt](https://coral.ai/docs/accelerator/get-started#runtime-on-linux):

```bash
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/coral-edgetpu-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/coral-edgetpu-keyring.gpg] https://packages.cloud.google.com/apt coral-edgetpu-stable main" | sudo tee /etc/apt/sources.list.d/coral-edgetpu.list
sudo apt update
sudo apt install libedgetpu1-std
# sudo apt install libedgetpu1-max
```

(Optionally) Build libedgetpu from source:

```bash
# Without Bazel:
# sudo apt install libabsl-dev libflatbuffers-dev
# git clone https://github.com/tensorflow/tensorflow $HOME/tensorflow
# cd $HOME/tensorflow && git checkout v2.16.1
git clone https://github.com/google-coral/libedgetpu $HOME/libedgetpu && cd $HOME/libedgetpu
TFROOT=$HOME/tensorflow make -f makefile_build/Makefile -j$(nproc) libedgetpu

# With Bazel:
go install github.com/bazelbuild/bazelisk@latest
sudo ln -s "$(go env GOPATH)/bin/bazelisk" /usr/local/bin/bazel
# Option 1. Using Docker:
DOCKER_CPUS="k8" DOCKER_IMAGE="ubuntu:22.04" DOCKER_TARGETS=libedgetpu make docker-build
DOCKER_CPUS="armv7a aarch64" DOCKER_IMAGE="debian:bookworm" DOCKER_TARGETS=libedgetpu make docker-build
debuild -us -uc -tc -b -a arm64 -d
# Option 2. Without Docker:
make
sudo apt install python3-dev
CPU=aarch64 make
debuild -us -uc -tc -b
```

Usage example:

```python
from tflite_runtime.interpreter import Interpreter, load_delegate

try:
    delegate = load_delegate('libedgetpu.so.1')
    print("Edge TPU delegate loaded successfully")

    interpreter = Interpreter(
        model_path='mobilenet_ssd_v2_coco_quant_postprocess_edgetpu.tflite',
        experimental_delegates=[delegate]
    )
    interpreter.allocate_tensors()
    print("Model loaded and tensors allocated")
except ValueError as e:
    print(f"Failed to load Edge TPU delegate: {e}")
    import traceback
    traceback.print_exc()
```

More examples:

- https://github.com/google-coral/tflite/tree/master/python/examples/classification

- https://github.com/google-coral/tflite/tree/master/python/examples/detection



## [Gasket Driver](https://github.com/google/gasket-driver)

Gasket: Gasket (Google ASIC Software, Kernel Extensions, and Tools) is a top level driver for lightweight communication with Google ASICs.

Apex: Apex refers to the EdgeTPU v1.

The Coral ("Apex") PCIe driver is required to communicate with any Edge TPU device over a PCIe connection. whereas the Edge TPU runtime provides the required programming interface for the Edge TPU.

**Note**: [`apt install gasket-dkms`](https://coral.ai/docs/m2/get-started#2-install-the-pcie-driver-and-edge-tpu-runtime) will **NOT** work.


### Kernel headers

Important prerequisite: Install [kernel headers](https://www.raspberrypi.com/documentation/computers/linux_kernel.html#kernel-headers) for your particular kernel version (`uname -r`).

Note: You will need to repeat this each time after upgrading kernel with `rpi-upgrade`:

```bash
sudo apt install linux-headers-rpi-v8
```

It can take several weeks to update the kernel headers package to reflect the latest kernel version. For the latest header versions, use [rpi-source](https://github.com/RPi-Distro/rpi-source) tool (it will extract headers from the kernel repo):

```bash
# sudo apt install git bc bison flex libssl-dev

# sudo curl -fsSL https://raw.githubusercontent.com/RPi-Distro/rpi-source/master/rpi-source -o /usr/local/bin/rpi-source
# sudo chmod +x /usr/local/bin/rpi-source

rpi-source --tag-update
rpi-source --default-config
```


###  Install gasket-driver from source

**Note**: gasket-driver is pretty much abandoned by Coral team, so you will need to apply some patches.

```bash
# sudo apt install -y devscripts debhelper dkms dh-dkms

# Remove existing package
sudo dpkg -r gasket-dkms

git clone https://github.com/google/gasket-driver.git
cd gasket-driver

# Apply patches
# curl -fsSL https://github.com/google/gasket-driver/pull/35.patch -o no_llseek.patch
curl -fsSL https://github.com/google/gasket-driver/pull/38.patch -o no_llseek_CONFIG_PM_SLEEP.patch
curl -fsSL https://github.com/google/gasket-driver/pull/40.patch -o MODULE_IMPORT_NS.patch
curl -fsSL https://github.com/google/gasket-driver/pull/42.patch -o dkms_deprecation.patch
find -type f -name *.patch -exec git apply -v {} \;

# Build debian package
debuild -us -uc -tc -b

# Install debian package from file
cd ..
sudo dpkg -i gasket-dkms_1.0-18_all.deb

# Without helper scripts, build and install:
# dpkg-buildpackage -us -uc -tc -b
# sudo dkms build gasket/1.0 -k `uname -r` --kernelsourcedir=/home/pi/linux
# sudo dkms install gasket/1.0
```


### udev rules to manage device permissions

```bash

sudo sh -c "echo 'SUBSYSTEM==\"apex\", MODE=\"0660\", GROUP=\"apex\"' >> /etc/udev/rules.d/65-apex.rules"
sudo groupadd apex
sudo adduser $USER apex
```


### Diagnostics

```bash
lspci -nn | grep 089a
# 0000:03:00.0 System peripheral [0880]: Global Unichip Corp. Coral Edge TPU [1ac1:089a]
# 0000:04:00.0 System peripheral [0880]: Global Unichip Corp. Coral Edge TPU [1ac1:089a]

lspci -vvv -d 1ac1:089a

sudo ls -la /dev/apex_*
dmesg | grep gasket
dmesg | grep apex
modinfo gasket
modinfo apex
lsmod | grep apex
```


## Installing PyCoral [PyCoral](https://github.com/google-coral/pycoral) for Google Coral on Raspberry Pi 5

Warning: PyCoral [requires very specific Python version](https://github.com/google-coral/pycoral/issues/85) (3.9) to be used:

```bash
git clone --recurse-submodules https://github.com/google-coral/pycoral

cd pycoral
git submodule init && git submodule update

examples/install_requirements.sh

scripts/build.sh --python_versions "39"
make wheel
pip3 install $(ls dist/*.whl)

python3 examples/classify_image.py \
    --model test_data/mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.tflite \
    --labels test_data/inat_bird_labels.txt \
    --input test_data/parrot.jpg
```

Better to install it in the Docker container environment with that specific Python version.

First, [install Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository):

```bash
# Non-CE:
sudo apt install docker.io

# Community Edition:
# Add Docker's official GPG key:
# sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Create PyCoral Docker Container:

```Docker
FROM debian:10 
 
WORKDIR /home 
ENV HOME /home 
RUN cd ~ 
RUN apt-get update 
RUN apt-get install -y git nano python3-pip python-dev pkg-config wget usbutils curl 
 
RUN echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" \ 
| tee /etc/apt/sources.list.d/coral-edgetpu.list 
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
RUN apt-get update 
RUN apt-get install -y edgetpu-examples 
```


```bash
# Build container and run PyCoral in Docker with Python 3.9

sudo docker build –t "coral" .

# Check host device is present:
ls /dev | grep apex

# Run container
# sudo docker run -it --device /dev/apex_0:/dev/apex_0 coral /bin/bash

# Or, with Dual Coral:
sudo docker run -it --device /dev/apex_0:/dev/apex_0 --device /dev/apex_1:/dev/apex_1 coral /bin/bash

# ...
python3 /usr/share/edgetpu/examples/classify_image.py \
    --model /usr/share/edgetpu/examples/models/mobilenet_v2_1.0_224_inat_bird_quant_edgetpu.tflite \
    --label /usr/share/edgetpu/examples/models/inat_bird_labels.txt \
    --image /usr/share/edgetpu/examples/images/bird.bmp
```


[Benchmarks](https://github.com/google-coral/pycoral/tree/master/benchmarks/)




# Patching msi-parent on the DTOverlay:

You should not need this. But in case you need, make sure you are absolutely aware of your actions and the consequences.

```bash
# Back up the Device Tree Blob (DTB)
sudo cp /boot/firmware/bcm2712-rpi-5-b.dtb /boot/firmware/bcm2712-rpi-5-b.dtb.bak

# Decompile the DTB into a DTS file
sudo dtc -I dtb -O dts /boot/firmware/bcm2712-rpi-5-b.dtb -o /tmp/i-know-what-i-am-doing.dts

# Modify the Device Tree Source (DTS)
sudo sed -i '/pcie@110000 {/,/};/{/msi-parent = <[^>]*>;/{s/msi-parent = <[^>]*>;/msi-parent = <0x67>;/}}' /tmp/i-know-what-i-am-doing.dts

# Recompile the DTS back into a DTB
sudo dtc -I dts -O dtb /tmp/i-know-what-i-am-doing.dts -o /tmp/i-know-what-i-am-doing.dtb

# Replace your current DTB with the new one
sudo mv /tmp/i-know-what-i-am-doing.dtb /boot/firmware/bcm2712-rpi-5-b.dtb
```


## Additional links

- https://www.jeffgeerling.com/blog/2023/pcie-coral-tpu-finally-works-on-raspberry-pi-5

- https://gist.github.com/dataslayermedia/714ec5a9601249d9ee754919dea49c7e (device tree edit instructions are outdated, skip)

- https://github.com/DAVIDNYARKO123/edge-tpu-silva (kinda outdated)

- [CodeProject](https://www.codeproject.com/AI/docs/install/running_in_docker.html) - a WebUI playground for TensorFlow Lite models:

    ```bash
    docker pull codeproject/ai-server:rpi64
    docker run --restart=always --name CodeProject.AI -d -p 32168:32168 \
    --privileged -v /dev/bus/usb:/dev/bus/usb codeproject/ai-server:rpi64
    # http://pi:32168
    ```


