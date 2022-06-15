# FROM ubuntu:18.04
FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04
# FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :10
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y sudo vim git wget curl zip unzip && \
    apt-get install -y net-tools iputils-ping && \
    apt-get install -y build-essential cmake && \
    apt-get install -y jupyter-core && \
    # For opencv (ImportError: libGL.so.1)
    apt-get install -y libgl1-mesa-glx && \
    # ImportError: libSM.so.6
    apt-get install -y libsm6 libxext6 libxrender-dev

# Install python3.8
RUN apt-get install -y software-properties-common && \
    apt-get install -y python3-pip python3.8-dev && \
    cd /usr/bin && \
    rm python3 && \
    ln -s python3.8 python && \
    ln -s python3.8 python3 && \
    ln -s pip3 pip && \
    pip install --upgrade pip


# CUDA 10.2
RUN pip3 install torch==1.8.0 torchvision==0.9.0 torchaudio==0.8.0

# CUDA 11.0
# RUN pip3 install torch==1.7.0+cu110 torchvision==0.8.1+cu110 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html

# CUDA 11.1
# RUN pip3 install torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio===0.8.1 -f https://download.pytorch.org/whl/torch_stable.html

# CUDA 11.3
# RUN pip3 install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio===0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

# Install python3.8 package
RUN pip3 install opencv-python && \
    pip3 install jupyter && \
    pip3 install matplotlib && \
    pip3 install pandas && \
    pip3 install sklearn && \
    pip3 install scikit-image && \
    pip3 install tensorboard

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