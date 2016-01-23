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
FROM node:slim

MAINTAINER Jones Magloire @Joxit

ENV NPM_CONFIG_LOGLEVEL=warn USER_ID=0

WORKDIR /opt/kosmtik

COPY kosmtik /bin/kosmtik

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && git clone https://github.com/kosmtik/kosmtik.git . \
    && npm install \
    && node index.js plugins --install kosmtik-tiles-export \
    && node index.js plugins --install kosmtik-fetch-remote \
    && node index.js plugins --install kosmtik-overlay \
    && apt-get autoremove -y --purge git \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /bin/kosmtik

WORKDIR /opt/project

EXPOSE 6789

CMD ["kosmtik", "serve"]
