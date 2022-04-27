# docker-plakar [WIP]

## About

Run [plakar][plakar-href] using `docker` commands.

## Overview

Plakar is a backup solution.

:warning: Plakar is not ready for production usage at this moment.

More information available in [plakar documenation][plakar-href].

Docker image is based on Alpine and available for amd64/arm64 arch.

## Requirements

* [Docker][docker-href]
* [docker-compose][docker-compose-href] (optional)

## Usage

Plakar is a powerful tool which allows remote or local backup.
Basicaly it uses a folder to store backup as snapshots.

### docker-compose (recommanded for server mode)

Use docker-compose to launch many plakar server on the same host.
One plakar server can not process many client at the same time.

Clone and customize docker-compose.yml file, then run:

```bash
docker-compose -f /path/to/your/docker-compose.yml up -d
```

:warning: Don't forget to update volume for each plakar

### docker run

#### start plakar server (optional)

```bash
docker run --rm \
 -v /data/plakar:/plakar \
 -e INIT=true \
 -e P_PATH=/plakar/plakar1 \
 barcus/plakar \
 plakar on /plakar/plakar1 server
```

Here, backup will be stored in `/data/plakar/plakar1` on docker host.

#### remote backup

First, be sure you can access plakar server, then run:

```bash
docker run --rm
 -v /my_data_to_bkp:/data \
 barcus/plakar \
 plakar on plakar://plakar-server-ip:port push /data
```

#### local backup

Firstly, be sure the plakar has been created:

```bash
docker run --rm \
 -v /data/plakar:/plakar \
 barcus/plakar \
 plakar on /plakar/plakar1 create --no-encryption
```

Using this command, `plakar1` will be created on docker host in `/data/plakar`.

Then, to push a backup:

```bash
docker run --rm \
 -v /my_data_to_bkp:/data \
 -v /data/plakar:/plakar \
 barcus/plakar \
 plakar on /plakar/plakar1 push /data
```

The idea here is to push `/my_data_to_bkp` from local host to
local plakar `/data/plakar/plakar1`

[plakar-href]: https://plakar.io
[docker-compose-href]: https://docs.docker.com/compose
[docker-href]: https://docs.docker.com/install
