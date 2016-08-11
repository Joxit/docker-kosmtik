# docker-kosmtik

Light docker for ksomtik <https://github.com/kosmtik/kosmtik>
This docker is an alternative to the other kosmtik docker which is 2 times bigger.
This image contains almost all kosmtik plugins.

| Image name      | Image Size                                                                                                                                       | Image layers                                                                                                                                   |
| :-------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| joxit/kosmtik   | [![Image Size](https://img.shields.io/imagelayers/image-size/joxit/kosmtik/latest.svg)](https://imagelayers.io/?images=joxit/kosmtik:latest)     | [![Image Layers](https://img.shields.io/imagelayers/layers/joxit/kosmtik/latest.svg)](https://imagelayers.io/?images=joxit/kosmtik:latest)     |
| kosmtik/kosmtik | [![Image Size](https://img.shields.io/imagelayers/image-size/kosmtik/kosmtik/latest.svg)](https://imagelayers.io/?images=kosmtik/kosmtik:latest) | [![Image Layers](https://img.shields.io/imagelayers/layers/kosmtik/kosmtik/latest.svg)](https://imagelayers.io/?images=kosmtik/kosmtik:latest) |

## Kosmtik

Very lite but extendable mapping framework to create Mapnik ready maps with
OpenStreetMap data (and more).

For now, only Carto based projects are supported (with .mml or .yml config),
but in the future we hope to plug in MapCSS too.

**Alpha version, installable only from source**

### Lite

Only the core needs:

-   project loading
-   local configuration management
-   tiles server for live feedback when coding
-   exports to common formats (Mapnik XML, PNG…)
-   hooks everywhere to make easy to extend it with plugins

## Usage

### Get the docker image

You can get the image in three ways

From sources with this command : 

```sh
git clone https://github.com/Joxit/docker-kosmtik.git
docker build -t joxit/kosmtik docker-kosmtik
```

Or build with the url : 

```sh
docker build -t joxit/kosmtik github.com/Joxit/docker-kosmtik
```

Or pull the image from [docker hub](https://hub.docker.com/r/joxit/kosmtik/) : 

```sh
docker pull joxit/kosmtik
```

### Run

#### Database

First of all, you need a database with OSM datas. You can use a postgres database in a docker or on a computer.
If you want your database to be in a docker, I suggest you to use [openfirmware/postgres-osm](https://hub.docker.com/r/openfirmware/postgres-osm/) docker.

In order to fill this database, you can use [openfirmware/osm2pgsql](https://hub.docker.com/r/openfirmware/osm2pgsql/). You can download a continent or country on [geofabrik.de](http://download.geofabrik.de/) or the whole planet on [planet.osm.org](http://planet.osm.org/).

#### Project

To run a Carto project (or `.yml`, `.yaml`):

    docker run -d \
        -p 6789:6789 \
        -v /path/to/your/project:/opt/project \
        --link postgres-osm:postgres-osm \
        -e USER_ID=1000 \
        joxit/kosmtik \
        kosmtik serve </opt/project/project.(mml|yml)> --host 0.0.0.0

The env `USER_ID` is your user ID on your host. The shell kosmtik will perform a `chown -R $USER_ID:$USER_ID /opt/project` at the end of the import.
Then open your browser at <http://127.0.0.1:6789/>.

#### Try it

You can try kosmtik with [HDM CartoCSS](https://github.com/hotosm/HDM-CartoCSS) project.

You can add an alias in your .bashrc or .bash_aliases for kosmtik serve. You can use `KOSMTIK_OPTS` env to add your own docker options for kosmtik (such as --link postgres-osm:postgres-osm or --net postgres-osm for networks).

```sh
alias kosmtik="docker run -ti --rm -p 6789:6789 -v $(pwd):/opt/project -e USER_ID=1000 $KOSMTIK_OPTS joxit/kosmtik kosmtik serve --host 0.0.0.0"
```

Or use the shell in tools (add the folder in your PATH var). If you are using serve command, the shell will add --host 0.0.0.0 as arg.

### Plugins

#### Tiles export

To export tiles from your project (see [kosmtik-tiles-export plugin](https://github.com/kosmtik/kosmtik-tiles-export)):

    docker run -d \
        -v /path/to/your/project:/opt/project \
        --link postgres-osm:postgres-osm \
        -e USER_ID=1000 \
        joxit/kosmtik \
        kosmtik export /opt/project/project.(mml|yml) \
        --format tiles --output /opt/project/tiles --minZoom 1 --maxZoom 13

The env `USER_ID` is your user ID on your host. The shell kosmtik will perform a `chown -R $USER_ID:$USER_ID /opt/project` at the end of the import.

#### Fetch remote

Download the remote files referenced in your layers and update their name to use them automatically (see [kosmtik-fetch-remote plugin](https://github.com/kosmtik/kosmtik-fetch-remote)).
Kosmtik is launched as root in the docker, so fetched datas and tmp tiles will be owned by root.
This is why you should use kosmtik cmd which will chown the curent directory (/opt/project) with your user id.

#### Overlay

You can add an `overlay` key to your `project.mml` or your kosmtik `config.yml`
files to override the behaviour (see [kosmtik-overlay plugin](https://github.com/kosmtik/kosmtik-overlay)). For example:

```yml
overlay:
    url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    active: true
    opacity: 1
    position: -1
```

```json
"overlay": {
    "url": "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    "active": true,
    "opacity": 1,
    "position": -1
}
```

#### Overpass layer

Just add "type": "overpass" and a request key with your overpass query in your Carto layer. The plugin will run the queries, cache them on disk, and transform the layers in normal geojson layers (see [kosmtik-overpass-layer pugin](https://github.com/kosmtik/kosmtik-overpass-layer)). 

#### Map compare

You can add `compareUrl` key to your project.mml or your kosmtik config.yml files to set the default URL used (see [kosmtik-map-compare plugin](https://github.com/kosmtik/kosmtik-map-compare)).
Fallback to OSM default style. For example:

```yml
compareUrl: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
```

```json
"compareUrl": "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
```

#### Place search

Add a search control (base on Photon) to your Kosmtik instance, you can use `CTRL + F` shortcut (see [kosmtik-place-search plugin](https://github.com/kosmtik/kosmtik-place-search)).

#### GeoJSON overlay

Show a geojson overlay on top of your Kosmtik map (see [kosmtik-geojson-overlay](https://github.com/kosmtik/kosmtik-geojson-overlay/blob/master/front.js)).

## Local config

Because you often need to change the project config to match your
local env, for example to adapt the database connection credentials,
kosmtik comes with an internal plugin to manage that. You have two
options: with a json file named `localconfig.json`, or with a js module
name `localconfig.js`.

Place your localconfig.js or localconfig.json file in the same directory as your 
carto project (or `.yml`, `.yaml`).

In both cases, the behaviour is the same, you create some rules to target
the configuration and changes the values. Those rules are started by the
keyword `where`, and you define which changes to apply using `then`
keyword. You can also filter the targeted objects by using the `if` clause.
See the examples below to get it working right now.

### Example of a json file

```json
[
    {
        "where": "center",
        "then": [29.9377, -3.4216, 9]
    },
    {
        "where": "Layer",
        "if": {
            "Datasource.type": "postgis"
        },
        "then": {
            "Datasource.dbname": "gis",
            "Datasource.password": "",
            "Datasource.user": "osm",
            "Datasource.host": "postgres-osm"
        }
    },
    {
        "where": "Layer",
        "if": {
            "id": "hillshade"
        },
        "then": {
            "Datasource.file": "/data/layers/hillshade.vrt"
        }
    }
]
```

### Example of a js module

```javascript
exports.LocalConfig = function (localizer, project) {
    localizer.where('center').then([29.9377, -3.4216, 9]);
    localizer.where('Layer').if({'Datasource.type': 'postgis'}).then({
        "Datasource.dbname": "gis",
        "Datasource.password": "",
        "Datasource.user": "osm",
        "Datasource.host": "postgres-osm"
    });
    // You can also do it in pure JS
    project.mml.bounds = [1, 2, 3, 4];
};
```
