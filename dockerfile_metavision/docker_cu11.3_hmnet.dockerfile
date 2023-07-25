# FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04
FROM nvidia/cudagl:11.3.0-devel-ubuntu20.04

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
# CUDA 11.3
RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113

# Install other packages for HMNet
RUN pip install hdf5plugin timm && \
    pip install torch-scatter -f https://data.pyg.org/whl/torch-1.12.1+cu113.html && \
    pip install "opencv-python>=4.5.5.64" "sk-video==1.1.10" && \
    pip install "numpy==1.23.4" pandas scipy

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