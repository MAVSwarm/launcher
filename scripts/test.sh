#!/bin/bash

if [ ${#} != 1 ]
then
    echo "usage: run_swarm.sh <sitl_drone_number>"
    exit -1
elif [ ${1} == "-h" -o ${1} == "--help" ]
then
    echo "usage: run_swarm.sh <sitl_drone_number>"
    exit -1
elif [ ! ${1} -gt 0 ]
then
    echo "usage: run_swarm.sh <sitl_drone_number>"
    exit -1
fi 

path=$(rospack find swarm_sitl_launcher)

if [ -e ${path} ]
then
    echo path exist
fi

echo $path
echo $GAZEBO_MODEL_PATH
export GAZEBO_MODEL_PATH=${GAEZBO_MODEL_PATH}:${path}/tmp/models
echo $GAZEBO_MODEL_PATH