# Command Central server setup

This project automates Command Central setup:

* Downloads latest fix level bootstrap installer for your platform
* Runs bootstrap installer
* Configures HTTP/S proxy
* Registers master repositories
* Uploads license keys
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

<!--
## Build and Test status of default branches

| AppVeyor (Windows)       | Travis CI (Linux / macOS) |
|--------------------------|--------------------------|
| [![Build status](https://ci.appveyor.com/api/projects/status/s8rcroq87awof16f/branch/release/102apr2018?svg=true)](https://ci.appveyor.com/project/sergeipogrebnyak/sagdevops-cc-server/branch/release/102apr2018) | [![Build Status](https://travis-ci.org/SoftwareAG/sagdevops-cc-server.svg?branch=release%2F102apr2018)](https://travis-ci.org/SoftwareAG/sagdevops-cc-server) |

-->

## Requirements

* Git client
* Internet access

To get started clone or fork this project (you will need to customize it)
and run git submodule initialization procedure to pull antcc library

```bash
git clone --recursive -b release/103oct2018 https://github.com/SoftwareAG/sagdevops-cc-server
cd sagdevops-cc-server
```

## Bootstrap Command Central server using Ant wrapper

To use bootstrap Ant wrapper script you need:

* Java 1.8
* [Apache Ant 1.9+](https://ant.apache.org/)

Verify by running:

```bash
java -version # MUST be 1.8+
ant -version  # MUST be 1.9+
```

Bootstrap the latest version of Command Central:

```bash
ant boot -Daccept.license=true
```

IMPORTANT: By setting ```accept.license=true``` property
you are accepting [End User License Agreement](http://documentation.softwareag.com/legal/general_license.txt)

The command will download the bootstrap installer for your operating system and run it for you.
This may take up to 30 minutes.
Then the installer is executed and the output would look like this:

```bash
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
sagccant waitcc
```

The bootstrap process is complete.

## Customizing bootstrap process

You can customize configuration for the bootstrap process.

Copy [bootstrap/default.properties](bootstrap/default.properties) into a new YOUR_BOOT_NAME.properties file.
Uncomment the following property to accept the license agreement:

```bash
accept.license=true
```

Review and modify any other properties as needed.

Run bootstrap process using the default properties file:

```bash
ant boot -Dbootstrap=YOUR_BOOT_NAME
```

NOTE: most of the properties are applicable only for a new bootstrap session. If you already bootstraped
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

Run this command to enter the credentials and store them in Command Central:

```bash
sagccant credentials
```

IMPORTANT: If you run this setup on a CI server you can pass credentials via environment variables:

```bash
export EMPOWER_USR=you@company.com
export EMPOWER_PSW=empowerpassword
sagccant credentials
```

See [Jenkinsfile](Jenkinsfile) for example.

Register all Software AG master repositories in Command Central:

```bash
sagccant masters
```

Verify successful master repositories setup:

```bash
sagccant test
```

### Import license keys

If you can skip this step if you plan on adding your license keys for each individual project,
however it is recommended to add all your license keys now.

Replace sample licenses/licenses.zip with your licenses.zip archive.

You can customize the location of the licenses archive in
environments/YOUR_ENV_NAME/env.properties by setting this property:

```bash
licenses.zip.url=http://url/to/licenses.zip
```

IMPORTANT: the structure of the licenses.zip is not important. Command Central will introspect
the archive and import found licences with auto generated aliases.

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

```bash
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
#mirror.spm=http://cc:8092
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

```bash
sagccant uninstall boot -Dbootstrap=YOUR_BOOT_NAME
sagccant up test -Denv=YOUR_ENV_NAME
```

> NOTE: `uninstall` target is currently not supported on Windows

The succesful test run will end with something like this:

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

Commit your changes to your target version control system, e.g. forked project on github or internal git repo.

Now you can pull and run this project on any other host to perform identical fully automated setup
of your customized Command Central server:

```bash
sagccant boot up -Dbootstrap=YOUR_BOOT_NAME -Denv=YOUR_ENV_NAME
```

## Cleanup

To uninstall Command Central run:

```bash
sagccant uninstall -Dbootstrap=YOUR_BOOT_NAME
```

> NOTE: `uninstall` target is currently not supported on Windows

_____________
Contact us at [TECHcommunity](mailto:technologycommunity@softwareag.com?subject=Github/SoftwareAG) if you have any questions.
___________________
These tools are provided as-is and without warranty or support. They do not constitute part of the Software AG product suite. Users are free to use, fork and modify them, subject to the license agreement. While Software AG welcomes contributions, we cannot guarantee to include every contribution in the master project.
