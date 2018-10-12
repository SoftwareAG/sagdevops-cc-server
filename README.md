# Command Central server setup

This project automates Command Central setup:

* Downloads latest fix level bootstrap installer for your platform
* Runs bootstrap installer
* Configures HTTP/S proxy
* Registers master repositories
* Registers license keys
* Uploads product and fix images
* Creates mirror repositories
* Imports default templates library

You can also use this project to maintain your Command Central installation:

* Pull the latest fixes and products into mirror repositories
* Update Command Central to the latest patch level
* Upgrade Command Central to a new release (from 9.x)
* Start/stop/restart Command Central
* Check jobs status and tail the logs
* Apply default and custom templates

## Build and Test status of default branches

| AppVeyor (Windows)       | Travis CI (Linux / macOS) |
|--------------------------|--------------------------|
| [![Build status](https://ci.appveyor.com/api/projects/status/s8rcroq87awof16f/branch/release/103oct2018?svg=true)](https://ci.appveyor.com/project/sergeipogrebnyak/sagdevops-cc-server/branch/release/103oct2018) | [![Build Status](https://travis-ci.org/SoftwareAG/sagdevops-cc-server.svg?branch=release%2F103oct2018)](https://travis-ci.org/SoftwareAG/sagdevops-cc-server) |

## Requirements

* Git client
* Internet access
* Java 1.8
* [Apache Ant 1.9+](https://ant.apache.org/)

Verify Java and Ant installation by running:

```bash
java -version # MUST be 1.8+
ant -version  # MUST be 1.9+
```

## Quick Start

> IMPORTANT: make sure you clone the repository with submodules by using `--recursive` switch:

```bash
git clone --recursive -b release/103oct2018 https://github.com/SoftwareAG/sagdevops-cc-server
cd sagdevops-cc-server
```

Perform default setup:

> IMPORTANT: by setting ```accept.license=true``` property
you are accepting [End User License Agreement](http://documentation.softwareag.com/legal/general_license.txt)

```bash
ant boot -Daccept.license=true
ant up test
```

When the process completes successfully open
[Command Central Web UI](https://localhost:8091/cce/web/) and login as Administrator/manage.

For a customization process follow the steps below.

## How to customize setup process

### Fork the project

Fork the project and clone it locally:

```bash
git clone --recursive -b release/103oct2018 https://github.com/YOURCCOUNT/sagdevops-cc-server
cd sagdevops-cc-server
```

### Customizing version, installation directory, ports and Administrator password

You can customize configuration for the bootstrap process.

Copy [bootstrap/default.properties](bootstrap/default.properties) into a new YOUR_BOOT_NAME.properties file.
Uncomment the following property to accept the license agreement:

```bash
accept.license=true
```

Review and modify any other properties as needed.

Run bootstrap process using the customized properties file:

```bash
ant boot -Dbootstrap=YOUR_BOOT_NAME
```

The downloaded bootstrap installer file will be reused (not downloaded again).

> NOTE: most of the properties are applicable only for a new bootstrap session. If you previously bootstraped
Command Central they will NOT apply until you uninstall first

```bash
ant uninstall boot
```

### Configuring Proxy

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
ant proxy -Denv=YOUR_ENV_NAME
```

or:

```bash
export CC_ENV=YOUR_ENV_NAME
ant proxy
```

### Registering master repositories for products and fixes

If this Command Central does not have access to the Internet you can skip this step.

> IMPORTANT: Your _gateway_ or _development_ Command Central should have access to the Internet.

To register master repositories Command Central needs your [Empower](https://empower.softwareag.com/) credentials
with permissions to download products and fixes.

Run this command to enter the credentials and store them in Command Central:

```bash
ant credentials
```

Register all Software AG master repositories in Command Central:

```bash
ant masters
```

Verify successful master repositories setup:

```bash
ant test
```

### Importing license keys

If you can skip this step if you plan on adding your license keys for each individual project,
however it is recommended to add all your license keys now.

Replace sample licenses/licenses.zip with your licenses.zip archive.

You can customize the location of the licenses archive in
environments/YOUR_ENV_NAME/env.properties by setting this property:

```bash
licenses.zip.url=http://url/to/licenses.zip
```

> IMPORTANT: the structure of the licenses.zip is not important. Command Central will introspect
the archive and import found licences with auto generated aliases.

Run this command to import license files:

```bash
ant licenses -Denv=YOUR_ENV_NAME
```

You can run this command again any time to add upload new license keys.

### Adding product and fix images

You can skip this step if you're planning to use only master and mirror repositories.

Use of image repositories is discouraged.

If you want to upload SAG Installer images to Command Central place the image
.zip files under _./images_/products folder.

If you want to upload SAG Update Manager images place the image
.zip files under _./images/fixes_ folder.

You can customize the location of the images folder in
environments/YOUR_ENV_NAME/env.properties
by setting this property:

```bash
images.dir=/path/to/images/
```

> IMPORTANT: the structure of the images.dir folder must be the following:

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
ant images -Denv=YOUR_ENV_NAME
```

You can run this command again any time to add upload new images.

### Creating mirror repositories

You should create mirror repositories to improve provisioning performance.

> NOTE: this process may take a long time and requires up to 10GB of space on average per release
if you mirror all products.

You can customize which release and which products/fixes to mirror using
environments/YOUR_ENV_NAME/env.properties
by setting these properties:

```bash
release=10.1
# from
mirror.repo.product=webMethods-${release}
mirror.repo.fix=Empower
# which products
mirror.products=productId1,productId2,...
# which platforms
mirror.platforms=W64,LNXAMD64,OSX
# hosting spm URL
mirror.spm=http://CCHOST:8092
```

> TIP: To find out product ids, open Command Central Web UI, webMethods-${release} repository content view
and tick _Show ID Column_ checkbox in the gear menu.

To start mirrors create or update process run:

```bash
ant mirrors -Denv=YOUR_ENV_NAME
```

> NOTE: fix mirror will download fixes only for the products in your product mirror
repository.

You can run this command again any time to pull the latest products/fixes from the upstream repos.

### Commit your changes to version control system

> IMPORTANT: To ensure your entire customized setup runs cleanly perform end-to-end run:

Adjust 'up' target in [build.xml](build.xml) with the targets that are applicable to your setup and run:

```bash
export CC_BOOT=YOUR_BOOT_NAME
export CC_ENV=YOUR_ENV_NAME

ant uninstall boot
ant up test
```

> NOTE: `uninstall` target is currently NOT supported on Windows

The successful test run will end with something like this:

```bash
[au:antunit] Environment configuration: environments/test/env.properties
[au:antunit] ------------- ---------------- ---------------
[au:antunit] Target: test-repos-master-prods took 1.103 sec
[au:antunit] Target: test-repos-master-fixes took 1.092 sec
[au:antunit] Target: test-repos-master-fixes-listing took 10.117 sec
[au:antunit] Target: test-repos-master-prods-listing took 48.337 sec

BUILD SUCCESSFUL
Total time: 41 minutes 27 seconds
```

Commit your changes to your target version control system, e.g. forked project on GitHub or internal git repo.

```bash
git commit -am 'customizations'
git push
```

## Setting up CI process

Clone default or forked project from GitHub and perform identical fully automated setup
of your customized Command Central server:

```bash
export CC_BOOT=YOUR_BOOT_NAME
export CC_ENV=YOUR_ENV_NAME

export EMPOWER_USR=you@company.com
export EMPOWER_PSW=*****

ant boot
ant up test
```

See examples of CI configuration files:

* [Jenkins](Jenkinsfile)
* [Travis CI](.travis.yml)
* [Appveyor CI](appveyor.yml)

## Launching Command Central Docker container

The fastest way to get Command Central up and running is to launch Docker container from the Docker Store.

> IMPORTNT: Please see [sagdevops-hello-docker](https://github.com/SoftwareAG/sagdevops-hello-docker) for getting started instructions.

```bash
EMPOWER_USR=you@company.com \
EMPOWER_PSW=**** \
docker-compose run --rm init
```

To setup mirrors run:

```bash
docker-compose run --rm init mirrors
```

## Creating staging environments on Software AG network

You can setup pre-released software staging environments
if you have access to Software AG network.

On Linux and Mac OS:

```bash
export CC_BOOT=staging
export CC_ENV=staging
export CC_VERSION=10.3-fix1

export EMPOWER_USR=you@softwareag.com
export EMPOWER_PSW=*****

export SAG_AQUARIUS=aquarius-dae.eur.ad.sag
export CC_INSTALLER_URL=http://aquarius-dae.eur.ad.sag/PDShare/cc

# for clean boxes, bootstrap antcc
# antcc/bootstrap/install.sh
# . ~/.bash_profile || . ~/.profile

ant boot
ant up staging test
```

On Windows:

```powershell
set CC_BOOT=staging
set CC_ENV=staging
set CC_VERSION=10.3-fix1

set EMPOWER_USR=you@softwareag.com
set EMPOWER_PSW=*****

set SAG_AQUARIUS=aquarius-dae.eur.ad.sag
set CC_INSTALLER_URL=http://aquarius-dae.eur.ad.sag/PDShare/cc

# for clean boxes, bootstrap ant+antcc
# .\antcc\bootstrap\install.ps1

ant boot
ant up staging test
```

On Docker:

```bash
CC_REG=daerepository03.eur.ad.sag:4443/ccdevops \
EMPOWER_USR=you@company.com \
EMPOWER_PSW=**** \
CC_ENV=staging \
docker-compose run --rm init staging
```

## Cleanup

Uninstall Command Central.

On Linux run:

```bash
ant uninstall -Dbootstrap=YOUR_BOOT_NAME
```

> NOTE: `uninstall` target is currently NOT supported on Windows

On Docker:

```bash
docker-compose down
```

_____________
Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.
___________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
