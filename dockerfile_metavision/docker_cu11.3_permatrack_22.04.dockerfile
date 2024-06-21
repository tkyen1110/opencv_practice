FROM ubuntu:22.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :0
ENV DEBIAN_FRONTEND=noninteractive

ENV PROJECT=permatrack
ENV TRT_VERSION=6.0.1.5
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ARG python=3.8
ENV PYTHON_VERSION=${python}

# # Set default shell to /bin/bash
# # SHELL ["/bin/bash", "-cu"]
# --allow-downgrades --allow-change-held-packages --no-install-recommends \
RUN apt-get update && apt-get install -y \ 
    build-essential \
    cmake \
    g++ \
    git \
    curl \
    docker.io \
    vim \
    wget \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    librdmacm1 \
    libibverbs1 \
    libgtk2.0-dev \
    zip \
    unzip \
    p7zip-full \
    bzip2 \
    htop \
    gnuplot \
    ffmpeg \
    sudo \
    ninja-build \
    lsb-core

# How to Install Python 3.8 on Ubuntu 22.04 or 20.04
# https://www.linuxcapable.com/install-python-3-8-on-ubuntu-linux/
RUN apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python3-tk \
    python3-pip

# Install cuda 11.3
# https://developer.nvidia.com/cuda-11.3.0-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_network
# https://github.com/NVIDIA/nvidia-docker/issues/1632
RUN 
# wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
# sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
# sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
# sudo apt-get update
# sudo apt-get -y install cuda

# RUN cd /usr/bin && \
#     rm g++ && \
#     ln -s g++-11 g++

# Install OpenSSH for MPI to communicate between containers
# RUN apt-get install -y --no-install-recommends openssh-client openssh-server && \
#     mkdir -p /var/run/sshd

# RUN ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python

# Install Pydata and other deps
# RUN pip install easydict scipy numpy pyquaternion matplotlib jupyter h5py \
#     awscli nuscenes-devkit tqdm progress path.py pyyaml opencv-python \
#     pycuda numba cython motmetrics scikit-learn moviepy imageio yacs \
#     tensorboardX torch_tb_profiler

# Install PyTorch
# RUN pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 && \
#     ldconfig

# RUN pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# RUN pip install git+https://github.com/achalddave/python-script-utils.git@v0.0.2#egg=script_utils

# Install Metavision SDK
# ADD metavision_4.2.1_22_04.list /etc/apt/sources.list.d
# RUN apt-get update && \
#     apt-get install -y metavision-sdk

# Set the home directory to our user's home.
ENV USER=$USER
ENV HOME="/home/$USER"

RUN echo "Create $USER account" &&\
    # Create the home directory for the new $USER
    mkdir -p $HOME &&\
    # Create an $USER so our program doesn't run as root.
    groupadd -r -g $GID $USER &&\
    useradd -r -g $USER -G sudo -u $UID -d $HOME -s /sbin/nologin -c "Docker image user" $USER &&\
    # Set the setuid bit
    # https://www.cbtnuggets.com/blog/technology/system-admin/linux-file-permissions-understanding-setuid-setgid-and-the-sticky-bit
    # chmod u+s /usr/bin/sudo  &&\
    # Set root user no password
    mkdir -p /etc/sudoers.d &&\
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    # Chown all the files to the $USER
    chown -R $USER:$USER $HOME

# Change to the $USER
WORKDIR $HOME
USER $USER