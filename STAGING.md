# Setting up Software AG internal staging environments

This document describes how to setup internal environments for
pre-released software from internal AQU servers and sandboxes.

## Requirements

* Access to the Software AG network
* Access to the Internet

## Running on Windows

Open PowerShell `Administrator` console and install the latest `antcc` client tool from
the AQU server of your choice:

```powershell
set CC_INSTALLER_URL=http://aquarius-dae.eur.ad.sag/PDShare/cc
set CC_VERSION=cc-def-10.3-milestone

antcc/bootstrap/install.ps1
```

Verify successfull tool setup:

```powershell
antcc -p
```

> IMPORTANT: you may need to close/reopen your PowerShell console to pick up the new environment variables

If you see the message that ends with `Default target: up` you're ready to proceed.

Bootstrap Command Central server:

```bat
set CC_INSTALLER_URL=http://aquarius-dae.eur.ad.sag/PDShare/cc

antcc boot -Daccept.license=true
```

Provide your credentials for the Empower SDC and internal AQU repositories access
and perform default server configuration:

```bat
set EMPOWER_USR=you@softwareag.com
set EMPOWER_PSW=*****

set SAG_AQUARIUS=aquarius-dae.eur.ad.sag
set CC_ENV=staging

antcc up
```

## Running on Linux or Mac OS

Open shell window and install the latest `antcc` client tool from
the AQU server of your choice:

```bash
export CC_INSTALLER_URL=http://aquarius-dae.eur.ad.sag/PDShare/cc
export CC_VERSION=cc-def-10.3-milestone

antcc/bootstrap/install.sh
```

Verify:

```bash
antcc -p
```

> IMPORTANT: you may need to close/reopen the shell window to pick up the new environment variables

If you see the message end with `Default target: up` you're ready to proceed.

Bootstrap Command Central server:

```bash
export CC_INSTALLER_URL=http://aquarius-dae.eur.ad.sag/PDShare/cc
export CC_BOOT=staging

antcc boot
```

Provide your credentials for the Empower SDC and internal AQU repositories access
and perform default server configuration:

```bash
export EMPOWER_USR=you@softwareag.com
export EMPOWER_PSW=*****

export SAG_AQUARIUS=aquarius-bg.eur.ad.sag
export CC_ENV=staging

antcc up
```
