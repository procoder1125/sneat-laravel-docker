FROM php:8.2-fpm-alpine AS example-baseimage

# System dependencies + Node.js + npm
RUN apk add --no-cache \
        bash \
        git \
        curl \
        unzip \
        zip \
        libzip-dev \
        libpq-dev \
        gnutls-dev \
        autoconf \
        build-base \
        nginx \
        supervisor \
        shadow \
        nodejs \
        npm \
        mysql-client \
        nano \
    && docker-php-ext-install pdo pdo_mysql \
    && pecl install pcov \
    && docker-php-ext-enable pcov \
    && rm -rf /var/cache/apk/*
