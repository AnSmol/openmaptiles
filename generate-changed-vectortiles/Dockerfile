FROM node:8
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>
WORKDIR /usr/src/app

RUN npm_config_user=root npm install -g \
        @mapbox/mbtiles \
        @mapbox/tilelive \
        tilelive-tmsource

VOLUME /tm2source /export
ENV SOURCE_PROJECT_DIR=/tm2source EXPORT_DIR=/export TILELIVE_BIN=tl
COPY . /usr/src/app/
CMD ["/usr/src/app/export-local.sh"]
