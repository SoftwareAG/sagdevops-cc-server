# Command Central server setup

This project automates Command Central setup

## Requirements

* [Apache Ant 1.9.x](https://ant.apache.org/)

To get started fork this project as you will need to customize it.

Then run git submodule initialization procedure to pull antcc library

```bash
git submodule init
git submodule update
```

Verify that your _antcc_ folder is not empty.

## How to bootstrap Command Central server

Download the latest Command Central bootstrap installer from 
[Empower](https://empower.softwareag.com/Products/DownloadProducts/sdc/default.asp) 
and save it under user's  ~/Downloads folder.

Edit [bootstrap/default.properties](bootstrap/default.properties) and uncomment the following property

```
accept.license=true
```

IMPORTANT: By setting ```accept.license=true``` property 
you are accepting [End User License Agreement](http://documentation.softwareag.com/legal/general_license.txt)


Make sure the name of the ```installer``` property matches the name of the installer
file that you downloaded

Review and customize other properties as needed.

Run bootstrap process

```bash
ant boot
```

Open Command Central Web UI at the URL printed at the end of the bootsrap process.

Verify client connectivity to the Command Central server.

```bash
ant waitcc
```


## How to apply default configuration

Default configuration includes:

* All public master repositories for products and fixes 
* Tuneup parameters for Command Central server

You will need [Empower](https://empower.softwareag.com/) credentials 
with permissions to download products and fixes.

Edit [environments/default/env.properties](environments/default/env.properties) file as set the following properties

* empower.username=YOUR_EMPOWER_USERNAME
* empower.password=YOUR_PASSWORD

Run configuration task

```bash
ant up
```

Verify successful setup by running tests

```bash
ant test
```

IMPORTANT: Ensure your setup runs cleanly end-to-end on a local machine.

```
ant uninstall boot up test 
```

Commit your changes. Now you can run this project on any other machine.

## TODO

* Create mirror repos
* Add custom licenses
* Add custom images

# Building Docker image with customized Command Central server

Before you start ensure you have installed [Docker](https://www.docker.com/products/overview) 

To build customized docker container run:

```bash
docker-compose up -d cc
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

Open https://localhost:8091/

To verify successful build run:

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
