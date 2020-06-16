# Copyright 2015-2016 Jones Magloire (Joxit)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM debian:buster-slim

LABEL maintainer="Jones Magloire @Joxit"

ENV NPM_CONFIG_LOGLEVEL warn
ENV USER_ID 0
ENV NODE_PATH /usr/lib/node_modules/
WORKDIR /opt/kosmtik

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates gpg gpg-agent \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && curl -sL https://github.com/kosmtik/kosmtik/archive/master.tar.gz | tar xz --strip-components=1 \
    && npm install --production \
    && npm uninstall npm \
    && node index.js plugins --install kosmtik-tiles-export \
    && node index.js plugins --install kosmtik-fetch-remote \
    && node index.js plugins --install kosmtik-overlay \
    && node index.js plugins --install kosmtik-deploy \
    && node index.js plugins --install kosmtik-overpass-layer \
    && node index.js plugins --install kosmtik-map-compare \
    && node index.js plugins --install kosmtik-mapnik-reference \
    && node index.js plugins --install kosmtik-osm-data-overlay \
    && node index.js plugins --install kosmtik-mbtiles-export \
    && node index.js plugins --install kosmtik-overpass-layer \
    && node index.js plugins --install kosmtik-place-search \
    && node index.js plugins --install kosmtik-geojson-overlay \
    && node index.js plugins --install kosmtik-open-in-josm \
    && apt-get autoremove -y --purge curl gpg gpg-agent \
    && rm -rf /var/lib/apt/lists/* ~/.npm/

COPY kosmtik /bin/kosmtik

WORKDIR /opt/project

EXPOSE 6789

CMD ["kosmtik", "serve"]
