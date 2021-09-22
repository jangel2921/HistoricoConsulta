FROM 367794562090.dkr.ecr.us-west-2.amazonaws.com/apipos-new

RUN apt-get install -y libpng-dev libfreetype6-dev libjpeg62-turbo-dev && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
docker-php-ext-install -j$(nproc) gd

# copy app in full.
WORKDIR /var/www/html/
COPY . /var/www/html/
COPY apache2.conf /etc/apache2/
COPY default.conf /etc/apache2/sites-available/000-default.conf
COPY default.conf /etc/apache2/sites-enabled/000-default.conf
# install dependencies
RUN composer global require hirak/prestissimo && composer install
EXPOSE 80
COPY php.ini-development /usr/local/etc/php/php.ini-development
COPY php.ini-production /usr/local/etc/php/php.ini-production
COPY mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

RUN chmod 777 -R /var/www/html/storage/ && \
    echo "Listen 8080" >> /etc/apache2/ports.conf && \
    echo CustomLog "/dev/stdout" access_log && \
    chown -R www-data:www-data /var/www/html/ && \
    chown -R www-data:www-data /var/www/dump/ && \
    a2enmod rewrite
COPY .env /var/www/html/.env
