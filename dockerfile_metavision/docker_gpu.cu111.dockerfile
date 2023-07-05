# FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04
FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu20.04

ARG USER=adev
ARG UID=1000
ARG GID=1000

ENV DISPLAY :0
ENV DEBIAN_FRONTEND=noninteractive

# Install basic apt packages
RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y sudo vim git wget curl zip unzip p7zip-full && \
    apt-get install -y net-tools iputils-ping && \
    apt-get install -y build-essential cmake

# Install apt packages
RUN apt-get install -y libnvidia-gl-470 && \
    apt-get install -y libcanberra-gtk-module libcanberra-gtk3-module

# Install python3.8
RUN apt-get install -y software-properties-common && \
    apt-get install -y python3-pip python3-tk && \
    apt-get install -y python3.8-dev && \
    cd /usr/bin && \
    rm python3 pip && \
    ln -s python3.8 python && \
    ln -s python3.8 python3 && \
    ln -s pip3 pip


# conda
# conda create --name metavision_3.6_3 python=3.6
# conda activate metavision_3.6_3
# conda deactivate
# python3 -m pip install "opencv-python>=4.5.5.64" "sk-video==1.1.10" "fire==0.4.0" "numpy<=1.21" pandas scipy h5py
# python3 -m pip install jupyter jupyterlab matplotlib "ipywidgets==7.6.5"
# python3 -m pip install numba profilehooks "pytorch_lightning==1.5.10" "tqdm==4.63.0" "kornia==0.6.1"
# python3 -m pip install llvmlite "pycocotools==2.0.4" "seaborn==0.11.2" "torchmetrics==0.7.2"
# python3 -m pip install torch==1.8.2 torchvision==0.9.2 torchaudio==0.8.2 --extra-index-url https://download.pytorch.org/whl/lts/1.8/cu111
# python3 -m pip install einops


# module unload cuda/11.1
# module avail
# module load cuda/9.2
# module list
# conda create --name dcnv2_3.6 python=3.6
# conda install pytorch=0.4.1 cuda92 -c pytorch


# https://docs.prophesee.ai/stable/installation/linux.html#
# Install dependencies for Metavision SDK
RUN apt-get install -y libcanberra-gtk-module mesa-utils ffmpeg

RUN python3 -m pip install pip --upgrade && \
    python3 -m pip install "opencv-python>=4.5.5.64" "sk-video==1.1.10"  && \
    python3 -m pip install "fire==0.4.0" "numpy==1.23.4" pandas scipy h5py && \
    python3 -m pip install jupyter jupyterlab matplotlib "ipywidgets==7.6.5" && \
    python3 -m pip install einops

RUN apt-get install -y libboost-program-options-dev libeigen3-dev

# Install Metavision SDK
ADD metavision_4.2.1_20_04.list /etc/apt/sources.list.d
RUN add-apt-repository -y ppa:s-schmeisser/ogre-1.12 && \
    apt-get update && \
    apt-get install -y metavision-sdk && \
    apt install hdf5-plugin-ecf hdf5-plugin-ecf-dev

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

# For MinkowskiEngine
# https://github.com/NVIDIA/MinkowskiEngine
# RUN apt-get install -y libopenblas-dev && \
#     python3 -m pip install ninja

# cd MinkowskiEngine
# python setup.py install
# # To specify blas, CXX, CUDA_HOME and force CUDA installation, use the following command
# # export CXX=c++; export CUDA_HOME=/usr/local/cuda-11.1; python setup.py install --blas=openblas --force_cuda

# For chrischoy/SpatioTemporalSegmentation
# https://github.com/chrischoy/SpatioTemporalSegmentation/
RUN python3 -m pip install open3d

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
    # Set root user no password
    mkdir -p /etc/sudoers.d &&\
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER && \
    # Chown all the files to the $USER
    chown -R $USER:$USER $HOME

# Change to the $USER
WORKDIR $HOME
USER $USER