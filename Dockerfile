#
# Stage builder
#
FROM lambci/lambda:build-nodejs10.x AS builder

ARG NODE_ENV=production
ARG PG_VERSION=11.4

ENV INSTALL_PATH /var/task
ENV NODE_ENV ${NODE_ENV}
ENV PG_VERSION ${PG_VERSION}

## Build PG
WORKDIR /tmp/
RUN curl --output postgresql-$PG_VERSION.tar.gz \
    https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.gz \
    && tar zxvf postgresql-$PG_VERSION.tar.gz \
    && rm postgresql-$PG_VERSION.tar.gz

WORKDIR /tmp/postgresql-$PG_VERSION
RUN ./configure --without-readline && make && make install

## Prepare app
WORKDIR $INSTALL_PATH

ADD package*.json ./
RUN npm install

ADD . ./

RUN mkdir -p $INSTALL_PATH/bin/postgres-${PG_VERSION}
RUN cp /usr/local/pgsql/bin/pg_dump $INSTALL_PATH/bin/postgres-${PG_VERSION}/pg_dump
RUN cp /usr/local/pgsql/lib/libpq.so.5.* $INSTALL_PATH/bin/postgres-${PG_VERSION}/libpq.so.5

#
# Stage final
#
FROM lambci/lambda:nodejs10.x AS final

ARG NODE_ENV=production

ENV INSTALL_PATH /var/task
ENV NODE_ENV ${NODE_ENV}

WORKDIR $INSTALL_PATH

COPY --from=builder $INSTALL_PATH $INSTALL_PATH
