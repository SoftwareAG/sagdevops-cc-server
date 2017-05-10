
# Building Docker image with customized Command Central server

You can package all your customizations done above into a Docker image
so that you can quickly launch new instances of Command Central for each of
your CD stages or for CI testing.

## Requirements

Before you start ensure you have installed [Docker](https://www.docker.com/products/overview)
including docker-compose tool.

There are no other requirements. You don't even have to have local Java or Apache Ant.

## Building Docker image

By default the image build runs only 'masters licenses' targets. You can 
adjust that by modifying RUN command in the main [Dockerfile](Dockerfile).

IMPORTANT: to build Docker image all license and image files MUST be in default location
folders under this project. Docker sends all these files as build context. Docker cannot send files ouside
of the current folder!

NOTE: including product or fix image files and creating mirror repositories will significatly increase
Command Central Docker image size!

To build customized image for Command Central run:

```bash
docker-compose build cc
```
Successful execution will end with something like this

```bash
BUILD SUCCESSFUL
Total time: 1 minute 21 seconds
 ---> d17f77f1cfcb
Removing intermediate container 6ab350c69242
Successfully built d17f77f1cfcb
Creating sagdevopsccserver_cc_1
```

## Running custom built Command Central container

Run this command to launch your Command Central server container:

```bash
docker-compose up -d cc
```

Open [https://localhost:8091/](https://localhost:8091/)

To verify successful master repositories setup run:

```bash
docker-compose run --rm test 
```

NOTE: it may take few minutes to complete, depending on the network speed

The successful result would look like this

```bash
[au:antunit] Target: test-repos-fixes-listing took 1.082 sec
[au:antunit] Target: test-client took 0.181 sec
[au:antunit] Target: test-repos-prods took 1.057 sec
[au:antunit] Target: test-repos-prods-listing took 111.189 sec
[au:antunit] Target: test-repos-fixes took 1.065 sec

BUILD SUCCESSFUL
Total time: 1 minute 56 seconds
```

To cleanup running containers run:

```bash
docker-compose down
```
Now you can use the docker image you've built in any other project

```bash
docker run --name mycc -d -p 8091:8091 mycc:9.12
```
_____________
Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.
___________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
