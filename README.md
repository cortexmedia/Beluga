**Beluga Deploy**

** You know what it is **
Mostly a scavenge of bash scripts used to deploy docker containers of single-node configuration in Amazon EC2.

** What it's meant to solve **
  - Run dockerfiles to build them
  - Push them to repository
  - Pull them when connected to server by ssh
  - That's it!

** What do I need to use it **
  - A Unix compatible system with RSync, SSH and Bash.

** How stuff works **

  - BelugaLib.sh contains all the functions used to build docker containers and deploy them
  - PushToDevelopment.sh Basically pulls the images and start your stuff.
  - BuildDockerImagesAndPushToRepos.sh Builds the docker containers and send them to Cortex's private repository


** Configuration file structure **
Configuration related to deployment is stored in ContainerInfos.cfg

The structure used to grab all the infos related to a container is

* "LocalImageName;DockerFilePath;DockerImageName"

They are stored in a array.

Per example

IMAGES_TO_BUILD[0]="mrheaume/sample_project_web;.;sample_project_web"
IMAGES_TO_BUILD[1]="mrheaume/sample_project_db;DockerPostgres/;sample_project_db"
IMAGES_TO_BUILD[2]="mrheaume/sample_project_nginx;DockerNginx/;sample_project_nginx"
