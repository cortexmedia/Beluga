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
set -e
BASE_DIR=$( cd "../$( dirname "${BASH_SOURCE[0]}" )" && pwd )

show_help() {
    echo "Copyright (c) 2015 Cortex (cortex.bz)"
    echo "Beluga (0.0.1-alpha). Usage :"
    echo "beluga [--build args] [--deploy args]"
    echo "-b Build the docker container and push to repository"
    echo "-p Connects via ssh to remote host and pulls the images."
}

####################
# MAIN APP RUNTIME #
####################
for i in "$@"
do
case $i in
  -b=*|--build=*)
    "$BASE_DIR/scripts/BuildDockerImagesAndPushToRepos.sh"
    exit 0
    shift
    ;;
  -p=*|--pull=*)
    "$BASE_DIR/scripts/PushToDevelopment.sh"
    exit 0
    shift
    ;;
  *)
    show_help
    exit 0
    ;;
esac
done

show_help
