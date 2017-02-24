# Command Central server setup

This project automates Command Central setup

## Requirements

* You will need [Apache Ant](https://ant.apache.org/)
* To perform initial setup you will need direct Internet access

To get started clone or fork this project (you will need to customize it).

Then run git submodule initialization procedure to pull antcc library

```bash
git submodule init
git submodule update
```

Verify that your _antcc_ folder is not empty.


## Quick Start

Bootstrap the latest version of Command Central server:

```bash
ant boot -Daccept.license=true -Dinstall.dir=/where/to/install
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

Edit [bootstrap/default.properties](bootstrap/default.properties) and uncomment the following property
to accept the license agreement:

```
accept.license=true
```

Review and modify any other properties as needed.

Run bootstrap process using the default properties file:

```bash
ant boot
```

NOTE: most of the properties are applicable only for a new boostrap session. If you already bootstraped
Command Central they will NOT apply for this installation. 
You can re-bootstrap Command Central by running this command:

```bash
ant uninstall boot
```

The downloaded bootstrap installer file will be reused (not download again).


## Customizing Command Central configuration


### Tuneup Command Central server connectivity

If your connection to the Internet goes via proxy 
update [environments/default/env.properties](environments/default/env.properties) with 
your HTTP/S proxy configuration:

```
proxy.http.enabled=true
proxy.http.host=YOURPROXYHOST
proxy.http.port=8080
proxy.http.nonproxyhosts=localhost|.my.domain
```

Then run:

```bash
ant tuneup
```


### Register master repositories for products and fixes

To register master repositories Command Central must have Internet access
and [Empower](https://empower.softwareag.com/) credentials 
with permissions to download products and fixes.

```bash
ant masters
```

If credentials are not preconfigured in [environments/default/env.properties](environments/default/env.properties)
the command will ask you to provide the credentials and will store them in the configuration file.

```
empower.username=YOUR_EMPOWER_USERNAME
empower.password=YOUR_PASSWORD
```

Alternatively you can set the values using environment variables.

```bash
export EMPOWER_USER=you@company.com
export EMPOWER_PASS=youpass

ant masters
```

Verify successful master repositories setup run:

```bash
ant test
```

### Add license keys

Place your SAG products license key .xml files under _./licenses/<platform>_ folder.

You can customize the location of the licenses folder in 
[environments/default/env.properties](environments/default/env.properties)
by setting this property:

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

Run this command to import license files:

```bash
ant licenses
```

### Add product and fix images 

If you want to upload SAG Installer images to Command Central place the image 
.zip files under _./images_/products folder and run:

If you want to upload SAG Update Manager images place the image 
.zip files under _./images/fixes_ folder and run:

You can customize the location of the images folder in 
[environments/default/env.properties](environments/default/env.properties)
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
ant images
```

### Create mirror repositories

You should create mirror repositories to improve provisioning performance.
NOTE: that this process may take a long time and requires up to 10GB of space on average per release
if you mirror all products.

You can customize which release, and which products/fixes to mirror 
[environments/default/env.properties](environments/default/env.properties)
by setting this property:

```
release=9.x
mirror.products=productId1,productId2,...
```

TIP: To find out product ids, open Command Central Web UI, webMethods-9.x master repository content view
and tick _Show ID Column_ checkbox in the gear menu.

```bash
ant mirrors
```

NOTE: fix mirror will download fixes only for the products in your product mirror
repository.

You can run this command again any time to pull the latest fixes from the master repo.

### Complete setup

IMPORTANT: To ensure your entire customized setup runs cleanly perform end-to-end run:

```
ant uninstall boot up test 
```

Commit your changes to your forked project. 

Now you can checkout and run this project on any other machine to perform identical fully automated setup.

```
ant boot up 
```


# Building Docker image with customized Command Central server

## Requirements

Before you start ensure you have installed [Docker](https://www.docker.com/products/overview)
including docker-compose tool. 

There are no other requirements. You don't even have to have local Java or Apache Ant.

## Buiding Docker image

IMPORTANT: to build Docker image all license and image files MUST be in default location
folders under this project. Docker sends all these files as build context. Docker cannot send files ouside
of the current folder!

NOTE: including product or fix image files and creating mirror repositories will significatly increase
Command Central Docker image size!

To build customized image for Command Central:

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

Run

```bash
export 
docker-compose up -d cc
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


___________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
