# Coral Edge TPU

## Links

- https://github.com/google-coral/libedgetpu The Edge TPU Runtime (libedgetpu)
- https://github.com/google-coral/libcoral The Coral C++ library (libcoral)
- https://github.com/google-coral/pycoral The Coral Python library (PyCoral)
- https://github.com/google-coral/test_data Various models and other testing data
- https://github.com/google/gasket-driver Coral Gasket Driver (allows usage of the Coral EdgeTPU on Linux systems)

## rPi5 configuration

Add to the `/boot/firmware/config.txt`:

```conf
# Set 4k page size instead of 16k
kernel=kernel8.img

# Enable PCIe at gen 3 speed
dtparam=pciex1
dtparam=pciex1_gen=3

# Enable Pineboards Hat Ai
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

(Optionally) Install Bazel and build from source:

```bash
go install github.com/bazelbuild/bazelisk@latest
sudo ln -s "$(go env GOPATH)/bin/bazelisk" /usr/local/bin/bazel
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

Note: [`apt install gasket-dkms`](https://coral.ai/docs/m2/get-started#2-install-the-pcie-driver-and-edge-tpu-runtime) will NOT work.

[Install from sources](https://pineboards.io/blogs/tutorials/how-to-configure-the-google-coral-edge-tpu-on-the-raspberry-pi-5):

```bash
git clone https://github.com/google/gasket-driver.git
cd gasket-driver
dpkg-buildpackage -us -uc -tc -b
sudo dkms build gasket/1.0 -k `uname -r` --kernelsourcedir=/home/pi/linux
sudo dkms install gasket/1.0
# cd ..
# sudo dpkg -i gasket-dkms_1.0-18_all.deb
```

Important prerequisite: [Install kernel headers for your particular kernel](https://pineboards.io/blogs/tutorials/how-to-update-your-raspberry-pi-kernel-and-install-kernel-headers)

```bash
rpi-source --tag-update
rpi-source --default-config
```


### Diagnostics

```bash
lspci -nn | grep 089a
# 0000:03:00.0 System peripheral [0880]: Global Unichip Corp. Coral Edge TPU [1ac1:089a]
# 0000:04:00.0 System peripheral [0880]: Global Unichip Corp. Coral Edge TPU [1ac1:089a]

sudo ls -la /dev/apex_*
dmesg | grep gasket
dmesg | grep apex
modinfo gasket
modinfo apex
lsmod | grep apex
```


## [PyCoral](https://github.com/google-coral/pycoral)

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

Better to install it in the docker container with that specific python version:

→ https://pineboards.io/blogs/tutorials/installing-pycoral-for-google-coral-on-raspberry-pi-5

[Benchmarks](https://github.com/google-coral/pycoral/tree/master/benchmarks/)



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
