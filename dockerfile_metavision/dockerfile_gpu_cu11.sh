#!/bin/bash
# vim ~/.bashrc
# alias mv3_1='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec metavision_3.1.2 cuda_11.1_20.04_1 cuda_11.1_20.04_1'
# alias mv3_2='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec metavision_3.1.2 cuda_11.1_20.04_1 cuda_11.1_20.04_2'
# alias mv3_3='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec metavision_3.1.2 cuda_11.1_20.04_1 cuda_11.1_20.04_3'

# alias mv4_1='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec metavision_4.2.1 cuda_11.1_20.04_1 cuda_11.1_20.04_1'

# alias rvt_1='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec rvt_22.04 cuda_11.8_22.04_1 cuda_11.8_22.04_1'
# alias rvt_2='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec rvt_20.04 cuda_11.8_20.04_1 cuda_11.8_20.04_1'

# alias hmnet_1='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec hmnet cuda_11.3_20.04_1 cuda_11.3_20.04_1'
# alias hmnet_2='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec hmnet cuda_11.3_20.04_1 cuda_11.3_20.04_2'

# alias eovod_1='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec eovod cuda_11.1_20.04_1 cuda_11.1_20.04_1'

# alias permatrack_1='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec permatrack cuda_11.3_20.04_1 cuda_11.3_20.04_1'
# alias permatrack_2='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec permatrack cuda_11.3_20.04_2 cuda_11.3_20.04_2'
# alias permatrack_3='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec permatrack_18.04 cuda_11.3_18.04_1 cuda_11.3_18.04_1'
# alias permatrack_4='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec permatrack_22.04 cuda_11.3_22.04_1 cuda_11.3_22.04_1'

# alias mobilesam='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec mobilesam_20.04 cuda_11.3_20.04_1 cuda_11.3_20.04_1'
# alias mobilesam='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec mobilesam_22.04 cuda_11.7_22.04_1 cuda_11.7_22.04_1'

# alias mit='cd /home/tkyen/workspace/opencv_practice/dockerfile_metavision; ./dockerfile_gpu_cu11.sh exec mit_22.04 cuda_12.1_22.04_1 cuda_12.1_22.04_1'

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
echo "HOST_DIR_PATH   = "$HOST_DIR_PATH

# Host directory name
IFS='/' read -a array <<< "$HOST_DIR_PATH"
HOST_DIR_NAME="${array[-1]}"
echo "HOST_DIR_NAME   = "$HOST_DIR_NAME


if [ "$2" == "" ]
then
    NAME=""
else
    NAME="$2"
fi

if [ "$3" == "" ]
then
    IMAGE_TAG="image_tag"
else
    IMAGE_TAG=$3
fi

if [ "$4" == "" ]
then
    CONTAINER_TAG="container_tag"
else
    CONTAINER_TAG=$4
fi

echo "NAME            = "$NAME
echo "IMAGE_TAG       = "$IMAGE_TAG
echo "CONTAINER_TAG   = "$CONTAINER_TAG

IMAGE_NAME="$NAME:$IMAGE_TAG"
CONTAINER_NAME="${NAME}_$CONTAINER_TAG"
echo "IMAGE_NAME      = "$IMAGE_NAME
echo "CONTAINER_NAME  = "$CONTAINER_NAME

IFS='_' read -ra ARR <<< "$IMAGE_TAG"
CUDA_VERSION_IMAGE="${ARR[1]}"
IFS='_' read -ra ARR <<< "$CONTAINER_TAG"
CUDA_VERSION_CONTAINER="${ARR[1]}"

if [ $CUDA_VERSION_IMAGE != $CUDA_VERSION_CONTAINER ];
then
    echo "CUDA version of docker image and container should be the same."
    exit
fi

CUDA_VERSION=$CUDA_VERSION_IMAGE
echo "CUDA_VERSION    = "$CUDA_VERSION


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
                    -f docker_cu${CUDA_VERSION}_$NAME.dockerfile \
                    -t $IMAGE_NAME ."
             )
    Fun_EvalCmd "${lCmdList[*]}"

elif [ "$1" = "run" ]
then
    # Changing shmem size of a docker container
    # https://www.deepanseeralan.com/tech/changing-shmem-size-of-docker-container/
    # metavision_3.1.2:cuda_11.1_20.04_1 8880 6000
    # metavision_3.1.2:cuda_11.1_20.04_2 8881 6001
    # metavision_3.1.2:cuda_11.1_20.04_3 8882 6002
    # metavision_4.2.1:cuda_11.1_20.04_1 8885 6005
    # hmnet:cuda_11.3_20.04_1            8890 6010
    # hmnet:cuda_11.3_20.04_2            8891 6011
    # mobilesam:cuda_11.3_20.04_1        8915 6035
    # mobilesam_22.04:cuda_11.7_22.04_1  8916 6036
    case $CONTAINER_NAME in
        "metavision_3.1.2_cuda_11.1_20.04_1")
            HOST_API_PORT="8880"
            TENSOR_BOARD_PORT="6000"
            ;;
        "metavision_3.1.2_cuda_11.1_20.04_2")
            HOST_API_PORT="8881"
            TENSOR_BOARD_PORT="6001"
            ;;
        "metavision_3.1.2_cuda_11.1_20.04_3")
            HOST_API_PORT="8882"
            TENSOR_BOARD_PORT="6002"
            ;;
        "metavision_4.2.1_cuda_11.1_20.04_1")
            HOST_API_PORT="8885"
            TENSOR_BOARD_PORT="6005"
            ;;
        "hmnet_cuda_11.3_20.04_1")
            HOST_API_PORT="8890"
            TENSOR_BOARD_PORT="6010"
            ;;
        "hmnet_cuda_11.3_20.04_2")
            HOST_API_PORT="8891"
            TENSOR_BOARD_PORT="6011"
            ;;
        "eovod_cuda_11.1_20.04_1")
            HOST_API_PORT="8900"
            TENSOR_BOARD_PORT="6020"
            ;;
        "permatrack_18.04_cuda_11.3_18.04_1")
            HOST_API_PORT="8905"
            TENSOR_BOARD_PORT="6025"
            ;;
        "permatrack_cuda_11.3_20.04_1")
            HOST_API_PORT="8906"
            TENSOR_BOARD_PORT="6026"
            ;;
        "permatrack_cuda_11.3_20.04_2")
            HOST_API_PORT="8907"
            TENSOR_BOARD_PORT="6027"
            ;;
        "permatrack_cuda_11.3_22.04_1")
            HOST_API_PORT="8910"
            TENSOR_BOARD_PORT="6030"
            ;;
        "mobilesam_cuda_11.3_20.04_1")
            HOST_API_PORT="8915"
            TENSOR_BOARD_PORT="6035"
            MOBILESAM="7860"
            ;;
        "mobilesam_22.04_cuda_11.7_22.04_1")
            HOST_API_PORT="8916"
            TENSOR_BOARD_PORT="6036"
            MOBILESAM="7861"
            ;;
        "mit_22.04_cuda_12.1_22.04_1")
            HOST_API_PORT="8810"
            TENSOR_BOARD_PORT="6010"
            ;;
    esac

    lCmdList=(
                "docker run --gpus all -itd \
                    --privileged --shm-size=32g \
                    --restart unless-stopped \
                    --name $CONTAINER_NAME \
                    -v $HOST_DIR_PATH:/home/$USER/$HOST_DIR_NAME \
                    -v /tmp/.X11-unix:/tmp/.X11-unix \
                    -v /etc/localtime:/etc/localtime:ro \
                    --mount type=bind,source=$SCRIPT_PATH/.bashrc_$NAME,target=/home/$USER/.bashrc \
                    -p $HOST_API_PORT:8888 \
                    -p $TENSOR_BOARD_PORT:6006 \
                    -p $MOBILESAM:7860 \
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
