# docker-kosmtik
Light docker for ksomtik https://github.com/kosmtik/kosmtik
This docker is an alternative to the other kosmtik docker which is 2 times bigger.

| Image name | Image Size | Image layers |
| :---- | ---- | ---- |
| joxit/kosmtik | [![Image Size](https://img.shields.io/imagelayers/image-size/joxit/kosmtik/latest.svg)](https://imagelayers.io/?images=joxit/kosmtik:latest) | [![Image Layers](https://img.shields.io/imagelayers/layers/joxit/kosmtik/latest.svg)](https://imagelayers.io/?images=joxit/kosmtik:latest)
| kosmtik/kosmtik | [![Image Size](https://img.shields.io/imagelayers/image-size/kosmtik/kosmtik/latest.svg)](https://imagelayers.io/?images=kosmtik/kosmtik:latest) | [![Image Layers](https://img.shields.io/imagelayers/layers/kosmtik/kosmtik/latest.svg)](https://imagelayers.io/?images=kosmtik/kosmtik:latest)

## Kosmtik

Very lite but extendable mapping framework to create Mapnik ready maps with
OpenStreetMap data (and more).

For now, only Carto based projects are supported (with .mml or .yml config),
but in the future we hope to plug in MapCSS too.

**Alpha version, installable only from source**

### Lite

Only the core needs:

- project loading
- local configuration management
- tiles server for live feedback when coding
- exports to common formats (Mapnik XML, PNG…)
- hooks everywhere to make easy to extend it with plugins

## Usage
### Create image
You can build the image from sources with this command :
```sh
docker build -t joxit/kosmtik .
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

```
docker run -d \
    -p 6789:6789 \
    -v /path/to/your/project:/path/to/your/project \
    --link postgres-osm:postgres-osm \
    joxit/kosmtik \
    node index.js serve </path/to/your/project.mml> --host 0.0.0.0
```

Then open your browser at http://127.0.0.1:6789/.

#### Try it

You can try kosmtik with [HDM CartoCSS](https://github.com/hotosm/HDM-CartoCSS) project.

### Plugins

#### Tiles export
To export tiles from your project (see [kosmtik-tiles-export plugin](https://github.com/kosmtik/kosmtik-tiles-export)):

```
docker run -d \
    -v /path/to/your/project:/path/to/your/project \
    -v /path/to/output/dir/:/data \
    --link postgres-osm:postgres-osm \
    joxit/kosmtik \
    node index.js export /path/to/your/project.yml \
    --format tiles --output /data --minZoom 1 --maxZoom 13
```
#### Fetch remote

Download the remote files referenced in your layers and update their name to use them automatically.

#### Overlay

You can add an `overlay` key to your `project.mml` or your kosmtik `config.yml`
files to override the behaviour. For example:

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
