#!/bin/bash

# Color
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

# Absolute path to this script.
# e.g. /home/ubuntu/opencv_practice/dockerfile/dockerfile_opencv.sh
SCRIPT=$(readlink -f "$0")

# Absolute path this script is in.
# e.g. /home/ubuntu/opencv_practice/dockerfile
SCRIPT_PATH=$(dirname "$SCRIPT")

# Absolute path to the opencv path
# e.g. /home/ubuntu/opencv_practice
HOST_DIR_PATH=$(dirname "$SCRIPT_PATH")
echo "HOST_DIR_PATH  = "$HOST_DIR_PATH

# Host directory name
IFS='/' read -a array <<< "$HOST_DIR_PATH"
HOST_DIR_NAME="${array[-1]}"
echo "HOST_DIR_NAME  = "$HOST_DIR_NAME


if [ "$2" == "" ]
then
    VERSION=""
else
    VERSION="$2"
fi

if [ "$3" == "" ]
then
    TAG="v1.0"
else
    TAG=$3
fi

echo "VERSION        = "$VERSION
echo "TAG            = "$TAG

IMAGE_NAME="metavision_$VERSION:$TAG"
CONTAINER_NAME="metavision_${VERSION}_$TAG"
echo "IMAGE_NAME     = "$IMAGE_NAME
echo "CONTAINER_NAME = "$CONTAINER_NAME

IFS=$'\n'
function Fun_EvalCmd()
{
    cmd_list=$1
    i=0
    for cmd in ${cmd_list[*]}
    do
        ((i+=1))
        printf "${GREEN}${cmd}${NC}\n"
        eval $cmd
    done
}

if [ "$1" == "build" ]
then
    export GID=$(id -g)

    lCmdList=(
                "docker build \
                    --build-arg USER=$USER \
                    --build-arg UID=$UID \
                    --build-arg GID=$GID \
                    -f docker_cu11.1_metavision_$VERSION.dockerfile \
                    -t $IMAGE_NAME ."
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "run" ]
then
    # Changing shmem size of a docker container
    # https://www.deepanseeralan.com/tech/changing-shmem-size-of-docker-container/
    # HOST_API_PORT="888${VERSION:1:1}"
    HOST_API_PORT="8885"
    TENSOR_BOARD_PORT="6005"

    lCmdList=(
                "docker run --gpus all -itd \
                    --privileged --shm-size=16g \
                    --restart unless-stopped \
                    --name $CONTAINER_NAME \
                    -v $HOST_DIR_PATH:/home/$USER/$HOST_DIR_NAME \
                    -v /tmp/.X11-unix:/tmp/.X11-unix \
                    -v /etc/localtime:/etc/localtime:ro \
                    --mount type=bind,source=$SCRIPT_PATH/.bashrc_$VERSION,target=/home/$USER/.bashrc \
                    -p $HOST_API_PORT:8888 \
                    -p $TENSOR_BOARD_PORT:6006 \
                    $IMAGE_NAME /home/$USER/$HOST_DIR_NAME/dockerfile_metavision/run_jupyter.sh" \
                "docker exec -it $CONTAINER_NAME /bin/bash"
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "exec" ]
then
    lCmdList=(
                "docker exec -it $CONTAINER_NAME /bin/bash"
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "start" ]
then
    lCmdList=(
                "docker start -ia $CONTAINER_NAME"
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "attach" ]
then
    lCmdList=(
                "docker attach $CONTAINER_NAME"
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "stop" ]
then
    lCmdList=(
                "docker stop $CONTAINER_NAME"
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "rm" ]
then
    lCmdList=(
                "docker rm $CONTAINER_NAME"
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "rmi" ]
then
    lCmdList=(
                "docker rmi $IMAGE_NAME"
             )
    Fun_EvalCmd "${lCmdList[*]}"

fi
