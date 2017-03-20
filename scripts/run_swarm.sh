#!/bin/bash

if [ ${#} != 1 ]
then
    echo "usage: run_swarm.sh <preset_name>"
    exit -1
elif [ ${1} == "-h" -o ${1} == "--help" ]
then
    echo "usage: run_swarm.sh <preset_name>"
    exit -1
fi


preset_name=${1}	#sitl drone numbers
swarm_sitl_launcher_path=$(rospack find swarm_sitl_launcher)
#rc_script=$3	#rc script name

source ${swarm_sitl_launcher_path}/presets/${preset_name}/config.sh

sim_port=15019
mav_port=15010
mav_port2=15011

mav_oport=15015
mav_oport2=15016

port_step=10

if [ -e ${swarm_sitl_launcher_path}/tmp ]
then
    rm -rf ${swarm_sitl_launcher_path}/tmp
    echo "cleared tmp folder"
fi

mkdir -p ${swarm_sitl_launcher_path}/tmp/posix

cd ${swarm_sitl_launcher_path}/tmp/posix

user=`whoami`
n=1
while [ ${n} -le ${drone_num} ]; do
 if [ ! -d ${n} ]; then
  mkdir -p ${n}
  cd ${n}

  mkdir -p rootfs/fs/microsd
  mkdir -p rootfs/eeprom
  touch rootfs/eeprom/parameters

  cat ${swarm_sitl_launcher_path}/presets/${preset_name}/init/${rcS} | sed s/_SIMPORT_/${sim_port}/ | sed s/_MAVPORT_/${mav_port}/g | sed s/_MAVOPORT_/${mav_oport}/ | sed s/_MAVPORT2_/${mav_port2}/ | sed s/_MAVOPORT2_/${mav_oport2}/ > rcS

  cd ..
 fi

 mkdir -p ${swarm_sitl_launcher_path}/tmp/models/${model_name}_${n}
 cat ${swarm_sitl_launcher_path}/presets/${preset_name}/models/${model_name}/${model_name}.sdf | sed s/_SIMPORT_/${sim_port}/ | sed s/_MODEL_NAME_/${model_name}_${n}/ > ${swarm_sitl_launcher_path}/tmp/models/${model_name}_${n}/${model_name}_${n}.sdf
 cat ${swarm_sitl_launcher_path}/presets/${preset_name}/models/${model_name}/model.config | sed s/_SDF_FILE_/${model_name}_${n}.sdf/ > ${swarm_sitl_launcher_path}/tmp/models/${model_name}_${n}/model.config
cp -r ${swarm_sitl_launcher_path}/presets/${preset_name}/models/${model_name}/meshes ${swarm_sitl_launcher_path}/tmp/models/${model_name}_${n}/meshes

 n=$((${n} + 1))
 sim_port=$((${sim_port} + ${port_step}))
 mav_port=$((${mav_port} + ${port_step}))
 mav_port2=$((${mav_port2} + ${port_step}))
 mav_oport=$((${mav_oport} + ${port_step}))
 mav_oport2=$((${mav_oport2} + ${port_step}))
done


export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${swarm_sitl_launcher_path}/tmp/models

roslaunch ${swarm_sitl_launcher_path}/presets/${preset_name}/launch/run_swarm.launch