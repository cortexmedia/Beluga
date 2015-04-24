#!/bin/bash
#######################################################################
# All information contained herein is, and remains
# the property of Cortex Media and its suppliers,
# if any.  The intellectual and technical concepts contained
# herein are proprietary to Cortex Media and its suppliers
# and may be covered by Canada and Foreign Patents,
# and are protected by trade secret or copyright law.
# Dissemination of this information or reproduction of this material
# is strictly forbidden unless prior written permission is obtained
# from Cortex Media.
#
# copyright    Cortex Media 2015
#
# author    Mathieu Rhéaume
#######################################################################
# File : BelugaDeployLib.sh
# URL : http://10.0.1.88/dokuwiki/doku.php?id=backenddockerbeluga
# Description : Beluga Docker Deployment lib.
# A scavenge of bash functions used to deploy docker containers.
#######################################################################
#######################################################################
# This is a list of index references to fit with IMAGES_TO_BUILD structure
# So we don't specify numbers everywhere
#######################################################################
ELOCALIMAGE=0
EDOCKERFILE=1
EDOCKERIMAGENAME=2

##########################################
# Function: stop_and_build_containers()
# Description : This stops the running
# containers and tries to build them if needed
##########################################
stop_and_build_containers() {
    run_ssh_command "cd $APP_DIRECTORY; docker-compose -f $DOCKER_COMPOSE_FILE stop; docker-compose -f $DOCKER_COMPOSE_FILE build "
}

##########################################
# Function: start_containers_in_background()
# Description : This starts the containers in
# background.
##########################################
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
        ssh "$DOCKER_USER@$SERVER_IP" $1
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
    rsync -r -v . "$SERVER_USER@$SERVER_IP:$APP_DIRECTORY"
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

