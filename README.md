![Alt text](/img/logo.png?raw=true "Beluga Cortex")

# **Beluga**
### **Intro**
We've decided to create Beluga in order to fix a very common problem that is the complexity of multi-tenants Docker installations. Indeed, Beluga enables you to quickly draft deployment scripts that will provide you with all the flexibility needed to quickly launch new projects using Docker. With Beluga, pre-setups are a thing of the past, the kickoff phase becomes extremely short which is an enourmous gain if you need to work with multiple clients/projects. Beluga has no run-time requirements for Linux operating machines and has pretty much no specific requirements outside of actially having Docker installed. Beluga also support private repositories without the need to use Docker Hub. 

### **Why you no use Kubernetes or Mesus?**

 - Currently Docker doesn't support Multi-Tenant environements
 - Therefore, neither Kubernetes and Mesos do from the docker/container layer...
 - Many actual issues : 
 - ```#2918 (PR: #4572) (container root is identical to host root -- volumes can be written and read from as host root inside container).```
- (WIP) Docker doesn't have any ACL. Writing to docker.sock == root.
-    ```#5619 (PR: #6000) (absolute symlinks and symlink path components copy host target).```
### **What Beluga Doesn't Do?**
- Down-to-distro cluster managements
- Docker registry or app management itself
- Magic service discovery
- Infrastructure management
### **How is it working?**
  - Run dockerfiles to build them
  - Push them to repository
  - Pull them when connected to server by ssh
  - That's it!

### **Requirements**
  - A Unix compatible system with RSync
  - SSH 
  - Docker Compose
  - Obviously, Docker..
  - Some love.
# **Install for OS X Systems using Homebrew**

    brew tap cortexmedia/beluga
    
  ### Stable version
     brew install beluga
  ### Latest version
     brew install --head beluga

#### **How Beluga works**
  - *scripts/* contains all the functions used to build docker containers and deploy them
  - *bin/beluga* Contains the CLI to call the various scripts.
  - *sample/* Example of BelugaFile.
  - *lib/* Common functions used by the various deployment scripts.

#### **Usage**
    
    beluga [--build args] [--deploy args] [options]
    -b Build the docker container and push to repository.
    -p Connects via ssh to remote host and pulls the images.
    -d Runs the build push and pull options.
    -c Connects via ssh and removed all unused tags and containers.
**Options:**
  ```  -f path/to/BelugaFile Specify the BelugaFile to use.```


##### **Configuration File**

  Configuration related to deployment is stored in BelugaFile.

  The structure used to grab all the infos related to a container is

```LocalImageName;DockerFilePath;DockerImageName```

  They are stored in a array like shown in the following example:

    IMAGES_TO_BUILD[0]="mrheaume/sample_project_web;.;sample_project_web"
    IMAGES_TO_BUILD[1]="mrheaume/sample_project_db;DockerPostgres/;sample_project_db"
    IMAGES_TO_BUILD[2]="mrheaume/sample_project_nginx;DockerNginx/;sample_project_nginx”
### **Sample Docker Project with Docker Compose**
    # docker-compose.yml 
    web:
        image: my_repository:8080/my-awesome-app 
    ports:
        - "5000:5000"
    links:
        - redis
        - nginx
    redis:
        image: my_repository:8080/redis
        nginx: image: nginx:latest
        
### **Contributing**

  The project is currently verified with Shellcheck for bash compatibility (http://www.shellcheck.net/).
  Feel free to ask for a Pull Request if you have awesome ideas for improvements or fixes to bugs.

### **Main Contributors**

  Mathieu Rhéaume <mrheaume@cortex.bz>

  **Copyright (c) 2015 Cortex (cortex.bz)**

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
