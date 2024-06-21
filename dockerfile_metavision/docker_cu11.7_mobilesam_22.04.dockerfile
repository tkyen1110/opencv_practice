FROM nvidia/cuda:11.7.1-devel-ubuntu22.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :0
ENV DEBIAN_FRONTEND=noninteractive

ARG python=3.10
ENV PYTHON_VERSION=${python}

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
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
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python3-pip \
    python3-tk \
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
    ninja-build

# Install OpenSSH for MPI to communicate between containers
RUN apt-get install -y --no-install-recommends openssh-client openssh-server && \
    mkdir -p /var/run/sshd

RUN ln -sf /usr/bin/python${PYTHON_VERSION} /usr/bin/python

# Install Pydata and other deps
# RUN pip install easydict scipy numpy pyquaternion matplotlib jupyter h5py \
#     awscli nuscenes-devkit tqdm progress path.py pyyaml opencv-python \
#     pycuda numba cython motmetrics scikit-learn==0.22.2 moviepy imageio yacs \
#     tensorboardX torch_tb_profiler \
RUN pip install opencv-python gradio timm torchpack onnx onnxsim onnxruntime numpy==1.26.4

# Install PyTorch
RUN pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 && \
    ldconfig

RUN pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'



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