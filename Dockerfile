FROM example-baseimage AS php

RUN apk add sudo

WORKDIR /app

ARG USERNAME=customuser
ARG GROUPNAME=customgroup
ARG UID=1000
ARG GID=1000

# 2️⃣ Yangi user yaratish
RUN addgroup --system --gid $GID $GROUPNAME \
    && adduser --system --ingroup $GROUPNAME --uid $UID $USERNAME

RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers    

# 3️⃣ PHP-FPM va Nginx konfiguratsiyasi
COPY docker/php/php.ini $PHP_INI_DIR/
COPY docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/php/conf.d/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini

COPY docker/nginx/nginx.conf docker/nginx/fastcgi_params docker/nginx/fastcgi_fpm docker/nginx/gzip_params /etc/nginx/
RUN mkdir -p /var/lib/nginx/tmp /var/log/nginx
RUN /usr/sbin/nginx -t -c /etc/nginx/nginx.conf

# Setup supervisor.
COPY docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

RUN chown -R $USERNAME:$GROUPNAME /usr/local/etc/php-fpm.d /var/lib/nginx /var/log/nginx

# 4️⃣ Loyiha fayllarini konteynerga nusxa ko‘chirish (artisan shu yerda mavjud bo‘ladi)
COPY --chown=$USERNAME:$GROUPNAME ./front/ .

RUN npm install
RUN npm run build

# 5️⃣ Composer tayyorlash va dependencylarni o‘rnatish
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
RUN composer install --no-dev --optimize-autoloader


# 6️⃣ Permissions
RUN chmod -R 775 /app/storage /app/vendor /app/bootstrap/cache \
    && chmod +w /app/public \
    && chown -R $USERNAME:$GROUPNAME /run /var /app/vendor

# 7️⃣ USER va entrypoint
USER $USERNAME

COPY docker/entrypoint.sh /app/docker/entrypoint.sh
ENTRYPOINT ["/app/docker/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]