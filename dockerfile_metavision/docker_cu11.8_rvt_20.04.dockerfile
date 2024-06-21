FROM nvidia/cuda:11.8.0-devel-ubuntu20.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :0
ENV DEBIAN_FRONTEND=noninteractive

ENV PYTHON_VERSION=3.9

RUN apt-get update && \
    apt-get install -y build-essential cmake g++ git curl \
    vim wget ca-certificates \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python3-tk \
    python3-pip \
    zip unzip p7zip-full bzip2 \
    htop sudo ninja-build

RUN ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python

# # Install PyTorch
# RUN pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu118

# # Install Pydata and other deps
# RUN pip install h5py==3.8.0 \
#     hydra-core==1.3.2 einops==0.6.0 torchdata==0.6.0 tqdm numba

# RUN pip install pytorch-lightning==1.8.6 wandb==0.14.0 \
#     pandas==1.5.3 plotly==5.13.1 opencv-python==4.6.0.66 tabulate==0.9.0 \
#     pycocotools==2.0.6 bbox-visualizer==0.1.0 StrEnum==0.4.10

# RUN pip install 'git+https://github.com/facebookresearch/detectron2.git'

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