# Command Central server setup

This project automates Command Central setup

## Requirements

* [Apache Ant 1.9.x](https://ant.apache.org/)

To get started fork this project as you will need to customize it.

## How to bootstrap Command Central server

Download the latest Command Central bootstrap installer from 
[Empower](https://empower.softwareag.com/Products/DownloadProducts/sdc/default.asp) 
and save it under user's  ~/Downloads folder.

Edit [bootstrap .properties](bootstrap/default.properties) and uncomment the following property

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

Edit [default env.properties](environments/default/env.properties) file as set the following properties

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


# Building Docker image with customized Command Central server

Before you start ensure you have installed [Docker](https://www.docker.com/products/overview) 

To build customized docker container run:

```bash
docker-compose up -d
open https://localhost:8091/
```

To verify successful build run:

```bash
docker-compose run --rm test 
```

To cleanup running containers run:

```bash
docker-compose down
```
