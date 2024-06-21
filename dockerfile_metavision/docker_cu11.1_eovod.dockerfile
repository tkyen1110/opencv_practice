# FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
FROM nvidia/cudagl:11.1.1-devel-ubuntu20.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :0
ENV DEBIAN_FRONTEND=noninteractive

# Install basic apt packages
# chmod 777 /tmp <= For apt-get update error
RUN chmod 777 /tmp && \
    apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y sudo vim git wget curl zip unzip p7zip-full && \
    apt-get install -y net-tools iputils-ping && \
    apt-get install -y build-essential cmake

# Install python3.8
RUN apt-get install -y software-properties-common && \
    apt-get install -y python3-pip python3-tk && \
    apt-get install -y python3.8-dev && \
    cd /usr/bin && \
    rm python3 pip && \
    ln -s python3.8 python && \
    ln -s python3.8 python3 && \
    ln -s pip3 pip

# Install PyTorch
# CUDA 11.1
RUN pip install torch==1.8.0+cu111 torchvision==0.9.0+cu111 torchaudio==0.8.0 -f https://download.pytorch.org/whl/torch_stable.html && \
    pip install mmcv-full==1.3.17 -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.8.0/index.html

# Install other packages
RUN pip install terminaltables, pycocotools

# cython, numpy && \
#     pip install cityscapesscripts, imagecorruptions, scipy, sklearn && \
#     pip install matplotlib, mmpycocotools, six, terminaltables && \
#     pip install asynctest, codecov, flake8, interrogate, isort==4.3.21, kwarray && \
#     pip install onnx==1.7.0, onnxruntime>=1.8.0, pytest, ubelt, xdoctest>=0.10.0, yapf

# Set the home directory to our user's home.
ENV USER=$USER
ENV HOME="/home/$USER"
ENV HDF5_PLUGIN_PATH="$HDF5_PLUGIN_PATH:/usr/lib/x86_64-linux-gnu/hdf5/plugins"

RUN echo "Create $USER account" &&\
    # Create the home directory for the new $USER
    mkdir -p $HOME &&\
    # Create an $USER so our program doesn't run as root.
    groupadd -r -g $GID $USER &&\
    useradd -r -g $USER -G sudo -u $UID -d $HOME -s /sbin/nologin -c "Docker image user" $USER &&\
    # Set the setuid bit
    # https://www.cbtnuggets.com/blog/technology/system-admin/linux-file-permissions-understanding-setuid-setgid-and-the-sticky-bit
    chmod u+s /usr/bin/sudo  &&\
    # Set root user no password
    mkdir -p /etc/sudoers.d &&\
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    # Chown all the files to the $USER
    chown -R $USER:$USER $HOME

# Change to the $USER
WORKDIR $HOME
USER $USER