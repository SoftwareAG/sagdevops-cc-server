[![Build Status](https://travis-ci.org/SoftwareAG/sagdevops-cc-server.svg?branch=master)](https://travis-ci.org/SoftwareAG/sagdevops-cc-server/builds)

# Command Central server setup

This project automates Command Central 9.12 and 10.0 setup:

* Downloads latest fix level bootstrap installer for your platform
* Runs bootstrap installer
* Configures HTTP/S proxy
* Registers master repositories
* Uploads license keys
* Uploads product and fix images
* Creates mirror repositories

You can also use this project to maintain your Command Central installation:

* Pull the latest fixes and products into mirror repositories
* Update Command Central to the latest patch level
* Upgrade Command Central to a new release (from 9.x to 9.12/10.0)
* Start/stop/restart Command Central
* Check jobs status and tail the logs

You can also build customized Command Central Docker image to 
launch containers using your favourite Docker orchestrator.


## Requirements

* Git client
* Internet access

To get started clone or fork this project (you will need to customize it)
and run git submodule initialization procedure to pull antcc library

```bash
git clone https://github.com/SoftwareAG/sagdevops-cc-server
cd sagdevops-cc-server
git submodule init
git submodule update
```

Verify that your _antcc_ folder is not empty.

## Bootstrap Command Central client

TIP: If you have Java 1.8+ and Apache Ant 1.9+ you can skip this section.


If you don't have Java or Ant on your system you can download and bootstrap
just the client that comes with Java and Ant distribution

For Linux:

```bash
curl -O http://empowersdc.softwareag.com/ccinstallers/cc-def-9.12-fix5-lnxamd64.sh
chmod +x cc-def-9.12-fix5-lnxamd64.sh
./cc-def-9.12-fix5-lnxamd64.sh -D CLI -d ~/.sag/cli
source ~/.bashrc
```

For Windows:

* Download [http://empowersdc.softwareag.com/ccinstallers/cc-def-9.12-fix5-w64.zip]
* Unzip cc-def-9.12-fix5-w64.zip
* Run (As Administrator) cc-def-9.12-release-w64 -D CLI -d %HOME%\.sag\cli


Verify by running in a new shell window:

```bash
sagccant -version # MUST be 1.9+
```

## Bootstrap Command Central using Ant wrapper

To use bootstrap Ant wrapper script you need:

* Java 1.8 
* [Apache Ant 1.8+](https://ant.apache.org/)

Verify by running: 

```bash
java -version # MUST be 1.8+
ant -version  # MUST be 1.9+
```

Bootstrap the latest version of Command Central 9.12:

```bash
ant boot -Daccept.license=true
```

To bootstrap Command Central 10.0 run this command instead:

```bash
ant boot -Daccept.license=true -Dbootstrap=10.0
```

IMPORTANT: By setting ```accept.license=true``` property 
you are accepting [End User License Agreement](http://documentation.softwareag.com/legal/general_license.txt)

The command will download the bootstrap installer for your operating system and run it for you.
This may take up to 30 minutes.
Then the installer is executed and the output would look like this:

```
[exec] ####
[exec] #### You can logon to Command Central Web UI as Administrator/manage
[exec] ####
[exec] ####     https://localhost:8091/cce/web
[exec] ####
[exec] #### You can also explore Command Central CLI commands by running from a NEW shell:
[exec] ####
[exec] ####     sagcc --help
[exec] ####
```

Open [Command Central Web UI](https://localhost:8091/cce/web/) using the URL printed above and login using
the specified credentials.

Verify client connectivity to the Command Central server:

```bash
ant waitcc
```

The bootstrap process is complete.


## Customizing bootstrap process

You can customize configuration for the bootstrap process.

Copy [bootstrap/default.properties](bootstrap/default.properties) into a new YOUR_BOOT_NAME.properties file.
Uncomment the following property to accept the license agreement:

```
accept.license=true
```

Review and modify any other properties as needed.

Run bootstrap process using the default properties file:

```bash
ant boot -Dbootstrap=YOUR_BOOT_NAME
```

NOTE: most of the properties are applicable only for a new boostrap session. If you already bootstraped
Command Central they will NOT apply for this installation. 
You can re-bootstrap Command Central by running this command:

```bash
ant uninstall boot -Dbootstrap=YOUR_BOOT_NAME
```

The downloaded bootstrap installer file will be reused (not downloaded again).

## Customizing Command Central configuration

### Configure proxy connection

If you have direct connection to the Internet you can skip this step.

If you have a proxy server copy [environments/default/env.properties](environments/default/env.properties) 
into a new environments/YOUR_ENV_NAME/env.properties file and update it with your HTTP/S proxy configuration:

```
proxy.http.host=YOURPROXYHOST
proxy.http.port=8080
proxy.http.nonproxyhosts=localhost|.my.domain
```

Then run:

```bash
sagccant proxy -Denv=YOUR_ENV_NAME
```


### Register master repositories for products and fixes

If this Command Central does not have access to the Internet you can skip this step.

IMPORTANT: Your _gateway_ or _development_ Command Central should have access to the Internet.

To register master repositories Command Central needs your [Empower](https://empower.softwareag.com/) credentials 
with permissions to download products and fixes.

When you run:

```bash
sagccant masters -Denv=YOUR_ENV_NAME
```

Command Central will check environments/YOUR_ENV_NAME/env.properties
first and if the credentials are not configured there it will ask you to provide them.
It then will store them in the env.properties file for later use.

```
empower.username=YOUR_EMPOWER_USERNAME
empower.password=YOUR_PASSWORD
```

Verify successful master repositories setup:

```bash
sagccant test -Denv=YOUR_ENV_NAME
```

### Add license keys

If you can skip this step if you plan on adding your license keys for each individual project,
however it is recommended to add all your license keys now.

Place your SAG products license key .xml files under _./licenses/<platform>_ folder.

You can customize the location of the licenses folder in 
environments/YOUR_ENV_NAME/env.properties by setting this property:

```
licenses.dir=/path/to/licenses/
```

IMPORTANT: the structure of the licenses.dir folder must be the following:

```
licenses\
   any\
      license-key-for-any-OS.txt
      license-key-for-any-OS.xml
      ...
   w64\
      any-windows-license-key.xml
      ...
   lnxamd64\
      any-linux-license-key.xml
      ...
   ...
```

Alternatively you can specify the URL to download the archive with our license files.
The folder structure of the .zip needs to be the same as above.

```
licenses.zip.url=http://YOUR_LICENSES.zip
```

Run this command to import license files:

```bash
sagccant licenses -Denv=YOUR_ENV_NAME
```

You can run this command again any time to add upload new license keys.

### Add product and fix images 

You can skip this step if you're planning to use only master and mirror repositories.

Use of image repositories is discouraged.

If you want to upload SAG Installer images to Command Central place the image 
.zip files under _./images_/products folder.

If you want to upload SAG Update Manager images place the image 
.zip files under _./images/fixes_ folder.

You can customize the location of the images folder in 
environments/YOUR_ENV_NAME/env.properties 
by setting this property:

```
images.dir=/path/to/images/
```

IMPORTANT: the structure of the images.dir folder must be the following:

```
products\
    my-9.12-products-lnxamd64.zip
    my-9.12-products-w64.zip
fixes\
    my-9.12-fixes.zip
    my-9.10-fixes.zip  
```

Run this command to upload image files:

```bash
sagccant images -Denv=YOUR_ENV_NAME
```

You can run this command again any time to add upload new images.

### Create mirror repositories

You should create mirror repositories to improve provisioning performance.

NOTE: this process may take a long time and requires up to 10GB of space on average per release
if you mirror all products.

You can customize which release and which products/fixes to mirror using 
environments/YOUR_ENV_NAME/env.properties 
by setting this property:

```
release=9.x
mirror.products=productId1,productId2,...
```

TIP: To find out product ids, open Command Central Web UI, webMethods-${release} repository content view
and tick _Show ID Column_ checkbox in the gear menu.

To start mirrors create or update process run:

```bash
sagccant mirrors -Denv=YOUR_ENV_NAME
```

NOTE: fix mirror will download fixes only for the products in your product mirror
repository.

You can run this command again any time to pull the latest products/fixes from the upstream repos.

### Commit your changes to version control system

IMPORTANT: To ensure your entire customized setup runs cleanly perform end-to-end run:

Adjust 'up' target in [build.xml](build.xml) with the targets that are applicable to your setup and run:

```
sagccant uninstall boot up test -Dboostrap=YOUR_BOOT_NAME -Denv=YOUR_ENV_NAME
```

The succesful test run will end with something like this:

```
[au:antunit] Environment configuration: environments/test/env.properties
[au:antunit] ------------- ---------------- ---------------
[au:antunit] Target: test-repos-master-prods took 1.103 sec
[au:antunit] Target: test-repos-master-fixes took 1.092 sec
[au:antunit] Target: test-repos-master-fixes-listing took 10.117 sec
[au:antunit] Target: test-repos-master-prods-listing took 48.337 sec

BUILD SUCCESSFUL
Total time: 41 minutes 27 seconds
```

Commit your changes to your target version control system, e.g. forked project on github or internal git repo.

Now you can pull and run this project on any other host to perform identical fully automated setup
of your customized Command Central server:

```
sagccant boot up -Dboostrap=YOUR_BOOT_NAME -Denv=YOUR_ENV_NAME
```

## Cleanup

To uninstall Command Central run:

```bash
ant uninstall -Dboostrap=YOUR_BOOT_NAME
```

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


___________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
