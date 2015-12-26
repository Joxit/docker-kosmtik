# Copyright 2015 Jones Magloire (Joxit)
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

MAINTAINER Jones Magloire (Joxit)

WORKDIR /opt/

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && git clone https://github.com/kosmtik/kosmtik.git \
    && cd kosmtik \
    && npm install \
    && node index.js plugins --install kosmtik-tiles-export \
    && node index.js plugins --install kosmtik-fetch-remote \
    && apt-get purge -y git \
    && apt-get autoremove -y --purge
WORKDIR /opt/kosmtik

EXPOSE 6789
VOLUME ["/data"]
CMD ["node", "index.js", "serve"]
