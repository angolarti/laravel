FROM php:7.4-fpm-alpine3.12 AS builder

# Este comando habilita o comando usermod
RUN apk add --no-cache openssl mysql-client bash nodejs npm
RUN docker-php-ext-install pdo pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /var/www
RUN rm -rf /var/www/html
COPY . /var/www
RUN ln -s public html

RUN composer install \
    && php artisan key:generate \
    && php artisan cache:clear \
    && chmod -R 755 storage
RUN npm install

FROM php:7.4-fpm-alpine3.12
RUN apk add --no-cache mysql-client
RUN docker-php-ext-install pdo pdo_mysql
WORKDIR /var/www
RUN rm -rf /var/www/html

COPY --from=builder /var/www .

EXPOSE 9000
ENTRYPOINT ["php-fpm"]