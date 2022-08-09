#!/bin/bash
# https://towardsdatascience.com/access-remote-code-in-a-breeze-with-jupyterlab-via-ssh-8c6a9ffaaa8c
# Run this on ssh client to do forwarding 
# ssh -N -L localhost:8888:localhost:8888 -p 21029 tkyen@cml0.csie.ntu.edu.tw

cuda_version=`nvcc -V | grep 10.2`
if [ -n "$cuda_version" ];
then
    ln -s /home/tkyen/opencv_practice/metavision/LIBTORCH_DIR_PATH/libtorch_cu102 /home/tkyen/libtorch
fi

cuda_version=`nvcc -V | grep 11.1`
if [ -n "$cuda_version" ];
then
    ln -s /home/tkyen/opencv_practice/metavision/LIBTORCH_DIR_PATH/libtorch_cu111 /home/tkyen/libtorch
fi

jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root

/bin/bash