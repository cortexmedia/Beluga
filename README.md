**Beluga Deploy**

** What it's meant to solve **
  - Run dockerfiles to build them
  - Push them to repository
  - Pull them when connected to server by ssh
  - That's it!

** What do I need to use it **
  - A Unix compatible system with RSync, SSH and Bash.

** How stuff works **

  - scripts/ contains all the functions used to build docker containers and deploy them
  - bin/beluga Contains the CLI to call the various scripts.
  
** Usage **
Copyright (c) 2015 Cortex (cortex.bz)
Beluga (0.0.1-alpha). Usage :
beluga [--build args] [--deploy args]
-b Build the docker container and push to repository.
-p Connects via ssh to remote host and pulls the images.
-d Runs the build push and pull options.
-c Connects via ssh and removed all unused tags and containers.

** Configuration file structure **
Configuration related to deployment is stored in BelugaFile

The structure used to grab all the infos related to a container is

* "LocalImageName;DockerFilePath;DockerImageName"

They are stored in a array.

Per example

IMAGES_TO_BUILD[0]="mrheaume/sample_project_web;.;sample_project_web"
IMAGES_TO_BUILD[1]="mrheaume/sample_project_db;DockerPostgres/;sample_project_db"
IMAGES_TO_BUILD[2]="mrheaume/sample_project_nginx;DockerNginx/;sample_project_nginx”
** Contributing **
The project is currently verified with Shellcheck for bash compatibility (http://www.shellcheck.net/).
Feel free to open Pull Request if you have awesome ideas for improvements or fixes to bugs.

** Main repo maintainers **
Mathieu Rhéaume <mrheaume@cortex.bz>
??
??
