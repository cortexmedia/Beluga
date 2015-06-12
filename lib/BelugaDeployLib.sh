#!/bin/bash
#######################################################################
# Copyright    2015 Cortex Media
# Author    Mathieu Rhéaume <mrheaume@cortex.bz>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#######################################################################
# File : BelugaDeployLib.sh
# Description : Beluga Docker Deployment lib.
# A scavenge of bash functions used to deploy docker containers.
#######################################################################
# This is a list of index references to fit with IMAGES_TO_BUILD structure
# So we don't specify numbers everywhere
#######################################################################
ELOCALIMAGE=0
EDOCKERFILE=1
EDOCKERIMAGENAME=2

################################################
# Function: remove_untagged_containers()       #
# Description : Remove the untagged containers #
################################################
remove_untagged_containers() {
  # Print containers using untagged images: $1 is used with awk's print: 0=line, 1=column 1.
  # NOTE: "[0-9a-f]{12}" does not work with GNU Awk 3.1.7 (RHEL6).
  run_ssh_command "docker ps -a | tail -n +2 | awk '\$2 ~ \"^[0-9a-f]+$\" {print \$1}' | xargs --no-run-if-empty docker rm"
}

################################################
# Function: remove_untagged_images()           #
# Description : Remove the untagged images     #
################################################
remove_untagged_images() {
  # Print untagged images: $1 is used with awk's print: 0=line, 3=column 3.
  # NOTE: intermediate images (via -a) seem to only cause
  # "Error: Conflict, foobarid wasn't deleted" messages.
  # Might be useful sometimes when Docker messed things up?!
  run_ssh_command "docker images | tail -n +2 | awk '\$1 == \"<none>\" {print \$3}' | xargs --no-run-if-empty docker rmi"
}

################################################
# Function: stop_and_build_containers()        #
# Description : This stops the running         #
# containers and tries to build them if needed #
################################################
stop_and_build_containers() {
  run_ssh_command "cd $APP_DIRECTORY; docker-compose -f $DOCKER_COMPOSE_FILE stop; docker-compose -f $DOCKER_COMPOSE_FILE build "
}

################################################
# Function: start_containers_in_background()   #
# Description : This starts the containers in  #
# background.                                  #
################################################
start_containers_in_background() {
  run_ssh_command "cd $APP_DIRECTORY; docker-compose -f $DOCKER_COMPOSE_FILE up -d "
}

################################################
# Function: rotate_containers()                #
# Description : This stops and start the       #
# containers and tries to build them if needed #
################################################
rotate_containers() {
  echo "Rotating docker-compose containers"
  stop_and_build_containers
  start_containers_in_background
}

#############################################
# Function: info_output()                   #
# Description : Output a info text in green #
# background.                               #
#############################################
# Arg 1 : Text to output as info            #
#############################################
info_output() {
  if [ -z "$1" ]
  then
    echo "YOU NEED TO PASS ME A TEXT"
  else
    echo "$(tput setaf 2)INFO: $1 $(tput sgr 0)"
  fi
}

#############################################
# Function: run_ssh_command()               #
# Description : Run a command over ssh with #
# Configuration settings                    #
#############################################
# Arg 1 : Command to run                    #
#############################################
run_ssh_command() {
  if [ -z "$1" ]
  then
    echo "YOU NEED TO SPECIFY A SSH COMMAND"
    exit 1
  else
      for i in "${SERVER_IP[@]}"
      do
        info_output "SSH $i - $1"
        ssh "$DOCKER_USER@$i" $1
      done
  fi
}

##############################################
# Function: pull_docker_image()              #
# Description : Pull a docker container over #
#               ssh on the target machine    #
##############################################
# Arg 1 : Container name                     #
##############################################
pull_docker_image() {
  if [ -z "$1" ]
  then
    echo "YOU NEED TO SPECIFY A CONTAINER NAME"
    exit 1
  else
    run_ssh_command "docker pull $1:latest"
  fi
}

#############################################
# Function: sync_app_files()                #
# Description : Sync files between host and #
#               target machine              #
#############################################
sync_app_files() {
      for i in "${SERVER_IP[@]}"
      do
        info_output "RSYNC $i"
        rsync -r . "$SERVER_USER@$i:$APP_DIRECTORY"
      done
}

##################################################################
# Function: clean_untagged_images()                              #
# Description : Removes all the old untagged docker containers.  #
#               This will skip over the running containers...    #
##################################################################
# ARG 1 : run over ssh on remote hosts                           #
##################################################################
clean_untagged_images() {
  if [ -z "$1" ]
  then
    run_ssh_command "docker rmi $(docker images | grep '<none>' | awk '{print($3)}')"
  else
    docker rmi "$(docker images | grep '<none>' | awk '{print($3)}')"
  fi
}

#################################################
# Function name: build_docker_image
# Description : This function runs a docker build
# on specified docker container name + docker container path
#################################################
# Arg 1 : Container name
# Arg 2 : Recipe folder
#################################################
build_docker_image() {
  if [ -z "$1" ] || [ -z "$2" ]
  then
    echo "You need to specify a container name and receipe folder"
    exit 1
  else
    info_output "Docker build $1 $2"
    docker build -t "$1" "$2"
    if [ $? -ne 0 ]; then
      echo "Docker build failed. Check your stuff mang or ask Chuck Norris"
      exit 1
    else
      echo "Just build $1 with $2"
    fi
  fi
}

#################################################
# Function name: tag_docker_image
# Description : This function runs a docker tags
# a container name with tag name
#################################################
# Arg 1 : Docker container name
# Arg 2 : Docker tag name
#################################################
tag_docker_image() {
  if [ -z "$1" ] || [ -z "$2" ]
  then
    echo "You need to specify a container name and tag name"
    exit 1
  else
    info_output "Docker tag $1 $2"
    docker tag -f "$1" "$2"
    if [ $? -ne 0 ]; then
      echo "Docker tag failed. Check your stuff mang or ask Chuck Norris."
      exit 1
    else
      echo "Just tagged $1 with $2"
    fi
  fi
}

#################################################
# Function name: push_docker_image
# Description : This function pushes the docker images
#################################################
# Arg 1 : Docker repository URL
# Arg 2 : Docker container name
#################################################
push_docker_image() {
  if [ -z "$1" ] || [ -z "$2" ]
  then
    echo "You need to specify a container name and repository"
    exit 1
  else
    info_output "Docker push $1 $2"
    docker push "$1/$2"
    if [ $? -ne 0 ]; then
      echo "Docker push failed. Check your stuff mang or ask Chuck Norris."
      exit 1
    else
      echo "Just pushed $1 to $2"
    fi

  fi
}

#################################################
# Function name: get_config_parameter
# Description : Extracts the selected parameter from string
# Mostly useful for parsing CSV-like strings
#################################################
# Arg 1 : CSV Formatted string
# Arg 2 : Index of item you want
#################################################
get_config_parameter() {
  if [ -z "$1" ] || [ -z "$2" ]
  then
    echo "You need to specify a configuration index and item index"
    exit 1
  else
    imageConfig=$1
    IFS=$ARRAY_DELIMITER read -a parsedconfig <<< "$imageConfig"
    echo "${parsedconfig[$2]}"
  fi
}

#################################################
# Function name: build_images
# Description : Build the docker images
#################################################
build_images() {
  echo "Building images"
  for i in "${IMAGES_TO_BUILD[@]}"
  do
    imageToBuild=$(get_config_parameter "$i" $ELOCALIMAGE)
    dockerFile=$(get_config_parameter "$i" $EDOCKERFILE)
    build_docker_image "$imageToBuild" "$dockerFile"
  done
}

#################################################
# Function name: tag_images
# Description : Tags the docker images
#################################################
tag_images() {
  echo "Tagging images"
  for i in "${IMAGES_TO_BUILD[@]}"
  do
    imageToBuild=$(get_config_parameter "$i" $ELOCALIMAGE)
    dockerFile=$(get_config_parameter "$i" $EDOCKERIMAGENAME)
    dockerTag=$REPOSITORY_URL"/"$dockerFile
    tag_docker_image "$imageToBuild" "$dockerTag"
  done
}

#################################################
# Function name: push_images
# Description : Pushes the docker images to repository
#################################################
push_images() {
  echo "Pushing images"
  for i in "${IMAGES_TO_BUILD[@]}"
  do
    dockerFile=$(get_config_parameter "$i" $EDOCKERIMAGENAME)
    push_docker_image "$REPOSITORY_URL" "$dockerFile"
  done
}

#################################################
# Function name: pull_images
# Description : Pulls the docker images to the target server from private repository
#################################################
pull_images() {
  echo "Pulling images"
  for i in "${IMAGES_TO_BUILD[@]}"
  do
    dockerFile=$(get_config_parameter "$i" $EDOCKERIMAGENAME)
    dockerTag=$REPOSITORY_URL"/"$dockerFile
    pull_docker_image "$dockerTag"
  done
}

