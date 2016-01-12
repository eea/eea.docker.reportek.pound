## Pound load balancer Docker image for Reportek

Docker image for Pound.


### Supported tags and respective Dockerfile links

  - `:latest` (default)

### Base docker image

 - [hub.docker.com](https://hub.docker.com/r/eeacms/reportek-pound)


### Source code

  - [github.com](http://github.com/eea/eea.docker.reportek.pound
)


### Installation

1. Install [Docker](https://www.docker.com/) **Please note**: version must not be 1.8.x due to docker issue [#16619](https://github.com/docker/docker/issues/16619) 
2. Install [Docker Compose](https://docs.docker.com/compose/install/).

## Usage

### Run with Docker Compose
Using Docker-Compose is the quickest way to start a container and connect the
available webapps through the 'links' parameter.
Here is a basic example of a `docker-compose.yml` file using the `eeacms/reportek-pound`
docker image:

    pound:
      image: eeacms/reportek-pound
      ports:
      - "8080:8080"
      env_file:
      - pound.env
      links:
      - webapp

    webapp:
      image: razvan3895/nodeserver


The application can be scaled to use more server instances, with `docker-compose scale`:

    $ docker-compose scale webapp=4 pound=1


### Run with backends specified as environment variable

    $ docker run --env BACKENDS="192.168.1.5:8080 192.168.1.6:8080" eeacms/reportek-pound:latest

The servers are written as `server_ip:server_listening_port`, separated by spaces
(and enclosed in quotes, to avoid issues). The contents of the variable are
evaluated in a bash script that writes the Pound configuration file automatically.


### Use a custom configuration file mounted as a volume

It is mandatory that the configuration file is mounted at /etc/pound/config.cfg

    $ docker run -v conf.d/pound.cfg:/etc/pound/config.cfg eeacms/reportek-pound:latest


This is the preferred way to start a container because the configuration file
can be modified locally at any time. In order for the modifications to be applied,
the configuration has to be reloaded, which can be done by running:

    $ docker exec <name-of-your-container> reload


## Supported environment variables ##

### pound.env ###

As Pound has close to no purpose by itself, this image should be used in
combination with others (for example with [Docker Compose](https://docs.docker.com/compose/))
Pound can be configured by modifying the following env variables,
either when running the container or in a `docker-compose.yml` file, preferably
by supplying an `.env` file in the appropriate tag.

* `ALIVE` Specify how often Pound will check for resurected back-end hosts - `default` 30 seconds
* `CLIENT` Specify for how long Pound will wait for a client request - `default` 10 seconds
* `TIMEOUT` How long should Pound wait for a response from the back-end - `default` 15 seconds
* `BACKENDS` The servers are written as `server_ip:server_listening_port`, separated by spaces (and enclosed in quotes, to avoid issues)
* `STICKY` If sticky sessions should be user - `default` off
* `SESSIONTYPE` Specify SESSIONTYPE
* `SESSIONCOOKIE` Specify SESSIONCOOKIE
* `SESSIONTIMEOUT` Specify SESSIONTIMEOUT

## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.


## Funding

[European Environment Agency (EU)](http://eea.europa.eu)
