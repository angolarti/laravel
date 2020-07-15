FROM php:7.4-fpm-alpine3.12

# Este comando habilita o comando usermod
RUN apk add --no-cache mysql-client bash
RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www
RUN rm -rf /var/www/html
# Não entra pk vamos usar volumes compartilhado
COPY . /var/www
RUN ln -s public html

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install && \
    cp .env.example .env && \
    php artisan key:generate && \
    php artisan config:cache

EXPOSE 9000
ENTRYPOINT ["php-fpm"]