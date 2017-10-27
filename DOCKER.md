# Running Command Central on Docker

* See [general information](README.md) on Command Central setup requirements.
* See [getting access to Docker images](https://github.com/SoftwareAG/sagdevops-hello-docker)

## Quick start Command Central server

```bash
export CC_PASSWORD=strongpass
export EMPOWER_USR=you@company.com
export EMPOWER_PSW=yourpass

docker-compose run --rm init
```

Open [Command Central Web UI](https://0.0.0.0:8091/cce/web/?entry=stacks#jobs:) and login as Administrator/strongpass

## Quick start Dev environment

To initialize couple of development nodes and Oracle XE db run:

```bash
docker-compose run --rm initdev
```

Open [Command Central Web UI](https://0.0.0.0:8091/cce/web/#) to see the results.

Here are properties that you can use to run against this environment:

```bash
nodes=dev1,dev2

db.url="jdbc:wm:oracle://oracledev:1521;SID=XE"
db.username=webm
db.password=webm

spm.host=dev1
spm.host2=dev2
```
