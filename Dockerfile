FROM docker.io/node:10-alpine as ghostinstall
ENV NODE_ENV development
ENV GOSU_VERSION 1.11

RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"; chmod a+x /usr/local/bin/gosu

RUN adduser -D ghostuser
RUN mkdir -p /srv/ghost; chown -R ghostuser:ghostuser /srv/ghost
RUN npm install -g "ghost-cli@$GHOST_CLI_VERSION"

RUN gosu ghostuser ghost install --db sqlite3 --no-prompt --no-stack --no-setup --dir /srv/ghost;
RUN npm install --prefix /srv/ghost/ ghost-google-cloud-storage-new; \
    npm cache clean --force
RUN mkdir -p /srv/ghost/content/adapters/storage/gcloud
RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage-new');\n" > /srv/ghost/content/adapters/storage/gcloud/index.js
RUN mkdir -p /srv/ghost/current/content/adapters/storage/gcloud
RUN printf "'use strict';\nmodule.exports = require('ghost-google-cloud-storage-new');\n" > /srv/ghost/current/content/adapters/storage/gcloud/index.js

FROM docker.io/node:10-alpine
ENV NODE_ENV production
COPY --from=ghostinstall /srv/ghost /srv/ghost
COPY config.production.json /srv/ghost/
RUN adduser -D ghostuser; chown -R ghostuser:ghostuser /srv/ghost
USER ghostuser:ghostuser

VOLUME /srv/ghost/content
WORKDIR /srv/ghost
CMD ["node", "current/index.js"]
