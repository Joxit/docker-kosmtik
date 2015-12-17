# docker-kosmtik
Light docker for ksomtik https://github.com/kosmtik/kosmtik

## Kosmtik

[![Join the chat at https://gitter.im/kosmtik/kosmtik](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/kosmtik/kosmtik?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Dependency Status](https://david-dm.org/kosmtik/kosmtik.svg)](https://david-dm.org/kosmtik/kosmtik)

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

To run a Carto project (or `.yml`, `.yaml`):

```
docker run -d -p 6789:6789 -v /path/to/your/project:/path/to/your/project joxit/kosmtik node index.js serve </path/to/your/project.mml>
```

Then open your browser at http://127.0.0.1:6789/.
