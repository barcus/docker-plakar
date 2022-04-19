# docker-plakar

## About

Run [plakar][plakar-href] using `docker run`

## Overview

Plakar is a backup solution.

:warning: Plakar is not ready for production usage at this moment.

Docker image is based on Alpine and available for amd64/arm64.

## Requirements

* [Docker][docker-href] & [docker-compose][docker-compose-href]

## Usage

### docker-compose (server)

Clone and customize docker-compose.yml file, then run:

```bash
docker-compose -f /path/to/your/docker-compose.yml up -d
```

:warning: Don't forget to update volume for each plakar

### docker run (client)

First, be sure you can access plakar server, then add
a cron job to run a backup:

```bash
docker run --rm -v /my_data_to_bkp:/data \
 barcus/plakar \
 plakar on plakar://plakar-server-ip:port push /data
```

[plakar-href]: https://plakar.io
[docker-compose-href]: https://docs.docker.com/compose
[docker-href]: https://docs.docker.com/install
