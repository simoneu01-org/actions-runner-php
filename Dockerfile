# syntax=docker/dockerfile:1

# GitHub's own runner image (Ubuntu 24.04, user "runner" with passwordless
# sudo), with what a Laravel project's CI would otherwise install on every
# job: PHP, Composer, Node and Playwright's Chromium.
#
# The build workflow passes the latest runner release; the default here is
# only for a local build.
ARG RUNNER_VERSION=2.338.0
ARG NODE_VERSION=24

FROM node:${NODE_VERSION}-bookworm-slim AS node

FROM ghcr.io/actions/actions-runner:${RUNNER_VERSION}

ARG PHP_VERSION=8.5

LABEL org.opencontainers.image.source="https://github.com/simoneu01-org/actions-runner-php"
LABEL org.opencontainers.image.description="GitHub Actions runner with PHP, Composer, Node and Playwright's Chromium"

USER root

ENV DEBIAN_FRONTEND=noninteractive

# PHP from Ondřej Surý's PPA, the source setup-php itself installs from, so
# setup-php finds the version already there and only switches to it.
# Xdebug is installed but off: setup-php turns it on for `coverage: xdebug`.
RUN add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-readline \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xdebug \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
    && phpdismod -v ${PHP_VERSION} -s ALL xdebug \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack

# Chromium's system libraries, and the browser itself in a shared folder. A
# project on the same Playwright version finds the browser already there; on
# another version, `playwright install` downloads its own next to it.
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
RUN npx -y playwright@latest install --with-deps chromium \
    && chown -R runner:runner /ms-playwright \
    && rm -rf /var/lib/apt/lists/* /root/.npm

USER runner

RUN php -v && composer --version && node --version && npm --version
