![Alt text](/img/logo.png?raw=true "Beluga Logo")

**Beluga**

** What it's meant to solve **
  - Run dockerfiles to build them
  - Push them to repository
  - Pull them when connected to server by ssh
  - That's it!

** What do I need to use it **
  - A Unix compatible system with RSync, SSH, Docker Compose, and obviously, Docker..

** How Beluga works **

  - scripts/ contains all the functions used to build docker containers and deploy them
  - bin/beluga Contains the CLI to call the various scripts.
  - sample/ Example of BelugaFile.
  - lib/ Common functions used by the various deployment scripts.

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

  They are stored in a array like shown in the following example:.

  Per example

    IMAGES_TO_BUILD[0]="mrheaume/sample_project_web;.;sample_project_web"
    IMAGES_TO_BUILD[1]="mrheaume/sample_project_db;DockerPostgres/;sample_project_db"
    IMAGES_TO_BUILD[2]="mrheaume/sample_project_nginx;DockerNginx/;sample_project_nginx”

** Contributing **

  The project is currently verified with Shellcheck for bash compatibility (http://www.shellcheck.net/).
  Feel free to ask for a Pull Request if you have awesome ideas for improvements or fixes to bugs.

** Main repo maintainers **

  Mathieu Rhéaume <mrheaume@cortex.bz>

  Copyright (c) 2015 Cortex (cortex.bz)

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
