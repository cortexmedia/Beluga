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
# File import from config file
# For more info or poke @mrheaume could prob. help around
# Please consult : http://10.0.1.88/dokuwiki/doku.php?id=backenddockerbeluga
#########################################################################
set -e

. "./BelugaFile"
. "$BASE_DIR/../lib/BelugaDeployLib.sh"

####################
# MAIN APP RUNTIME
####################
build_images
tag_images
push_images

