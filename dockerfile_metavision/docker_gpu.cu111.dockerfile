# FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04
FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :10
ENV DEBIAN_FRONTEND=noninteractive

ADD metavision.list /etc/apt/sources.list.d

# Install basic apt packages
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y sudo vim git wget curl zip unzip && \
    apt-get install -y net-tools iputils-ping && \
    apt-get install -y build-essential cmake

# Install apt packages
RUN apt-get install -y libnvidia-gl-515 && \
    apt-get install -y libcanberra-gtk-module libcanberra-gtk3-module
# RUN apt-get install -y jupyter-core && \
#     # For opencv (ImportError: libGL.so.1)
#     apt-get install -y libgl1-mesa-glx && \
#     # ImportError: libSM.so.6
#     apt-get install -y libsm6 libxext6 libxrender-dev

# Install python3.7
RUN apt-get install -y software-properties-common && \
    apt-get install -y python3-pip python3-tk && \
    apt-get install -y python3.7-dev && \
    cd /usr/bin && \
    rm python3 && \
    ln -s python3.7 python && \
    ln -s python3.7 python3 && \
    ln -s pip3 pip

# https://docs.prophesee.ai/stable/installation/linux.html#
# Install dependencies for Metavision SDK
RUN apt-get install -y libcanberra-gtk-module mesa-utils ffmpeg

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install "opencv-python>=4.5.5.64" "sk-video==1.1.10"  && \
    python3 -m pip install "fire==0.4.0" "numpy<=1.21" pandas scipy h5py && \
    python3 -m pip install jupyter jupyterlab matplotlib "ipywidgets==7.6.5"

RUN apt-get install -y libboost-program-options-dev libeigen3-dev

# Install Metavision SDK
RUN apt-get install -y metavision-sdk && \
    apt-get install -y metavision-sdk-python3.7

# Install Python package for Metavision SDK
# CUDA 10.2
# RUN pip install torch==1.8.2 torchvision==0.9.2 torchaudio==0.8.2 --extra-index-url https://download.pytorch.org/whl/lts/1.8/cu102

# CUDA 11.1
RUN pip install torch==1.8.2 torchvision==0.9.2 torchaudio==0.8.2 --extra-index-url https://download.pytorch.org/whl/lts/1.8/cu111

RUN python3 -m pip install numba llvmlite profilehooks "pytorch_lightning==1.5.10" && \
    python3 -m pip install "pycocotools==2.0.4" "tqdm==4.63.0" && \
    python3 -m pip install "torchmetrics==0.7.2" "seaborn==0.11.2" "kornia==0.6.1"

# Install LibTorch for C++ for Metavision SDK
# RUN wget https://download.pytorch.org/libtorch/cu111/libtorch-cxx11-abi-shared-with-deps-1.10.0%2Bcu111.zip

# Set the home directory to our user's home.
ENV USER=$USER
ENV HOME="/home/$USER"

RUN echo "Create $USER account" &&\
    # Create the home directory for the new $USER
    mkdir -p $HOME &&\
    # Create an $USER so our program doesn't run as root.
    groupadd -r -g $GID $USER &&\
    useradd -r -g $USER -G sudo -u $UID -d $HOME -s /sbin/nologin -c "Docker image user" $USER &&\
    # Set root user no password
    mkdir -p /etc/sudoers.d &&\
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    # Chown all the files to the $USER
    chown -R $USER:$USER $HOME

# Change to the $USER
WORKDIR $HOME
USER $USER