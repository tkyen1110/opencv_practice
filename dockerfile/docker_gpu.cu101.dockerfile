FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

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

# Install python2.7 and python3.6
RUN apt-get install -y python2.7 python-dev && \
    apt-get install -y python3.6 python3.6-dev python3.6-distutils && \
    apt-get install -y python3-tk && \
    cd /usr/bin && \
    rm python3 && \
    ln -s python3.6 python3 && \
    rm python && \
    ln -s python3.6 python

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /root/get-pip2.py && \
    python2 /root/get-pip2.py && \
    rm /root/get-pip2.py && \
    curl https://bootstrap.pypa.io/get-pip.py -o /root/get-pip3.py && \
    python3 /root/get-pip3.py && \
    rm /root/get-pip3.py

# Install python2.7 package
RUN pip2 install opencv-python==4.1.1.26

# Install python3.6 package
RUN pip3 install torch==1.7.0+cu110 torchvision==0.8.1+cu110 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html  && \
    pip3 install opencv-python && \
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