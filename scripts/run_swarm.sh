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


sitl_num=${1}	#sitl drone numbers
swarm_sitl_launcher_path=$(rospack find swarm_sitl_launcher)
#rc_script=$3	#rc script name

sim_port=15019
mav_port=15010
mav_port2=15011

mav_oport=15015
mav_oport2=15016

port_step=10

if [ -e ${swarm_sitl_launcher_path}/tmp ]
then
    rm -rf ${swarm_sitl_launcher_path}/tmp
fi

mkdir -p ${swarm_sitl_launcher_path}/tmp/posix

cd ${swarm_sitl_launcher_path}/tmp/posix

user=`whoami`
n=1
while [ ${n} -le ${sitl_num} ]; do
 if [ ! -d ${n} ]; then
  mkdir -p ${n}
  cd ${n}

  mkdir -p rootfs/fs/microsd
  mkdir -p rootfs/eeprom
  touch rootfs/eeprom/parameters

  cat ${swarm_sitl_launcher_path}/init/rcS_multiple_gazebo_iris | sed s/_SIMPORT_/${sim_port}/ | sed s/_MAVPORT_/${mav_port}/g | sed s/_MAVOPORT_/${mav_oport}/ | sed s/_MAVPORT2_/${mav_port2}/ | sed s/_MAVOPORT2_/${mav_oport2}/ > rcS

  cd ..
 fi

 mkdir -p ${swarm_sitl_launcher_path}/tmp/models/iris_${n}
 cat ${swarm_sitl_launcher_path}/models/iris/iris.sdf | sed s/_SIMPORT_/${sim_port}/ | sed s/_MODEL_NAME_/iris_${n}/ > ${swarm_sitl_launcher_path}/tmp/models/iris_${n}/iris_${n}.sdf
 cat ${swarm_sitl_launcher_path}/models/iris/model.config | sed s/_SDF_FILE_/iris_${n}.sdf/ > ${swarm_sitl_launcher_path}/tmp/models/iris_${n}/model.config
cp -r ${swarm_sitl_launcher_path}/models/iris/meshes ${swarm_sitl_launcher_path}/tmp/models/iris_${n}/meshes

 n=$((${n} + 1))
 sim_port=$((${sim_port} + ${port_step}))
 mav_port=$((${mav_port} + ${port_step}))
 mav_port2=$((${mav_port2} + ${port_step}))
 mav_oport=$((${mav_oport} + ${port_step}))
 mav_oport2=$((${mav_oport2} + ${port_step}))
done

export GAZEBO_MODEL_PATH=${GAEZBO_MODEL_PATH}:${swarm_sitl_launcher_path}/tmp/models

roslaunch swarm_sitl_launcher run_swarm.launch