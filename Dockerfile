FROM debian:7.9

RUN apt-get update && apt-get install curl wget vim openssl git -y
RUN echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list \
     && echo "deb http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list \
     && wget -qO - http://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update && apt-get install -y nginx php5-fpm php5-cli php5-mcrypt php5-gd php5-curl php5-mysql php5-pgsql \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && php5enmod mcrypt

RUN git clone https://github.com/paralin/invoice-ninja.git /var/www/invoice-ninja/ --recursive --depth=1
WORKDIR /var/www/invoice-ninja/
RUN composer install --no-dev -o

ADD nginx_site.conf /etc/nginx/sites-available/invoice_ninja
ADD invoice_ninja_fpm.conf /etc/php5/fpm/pool.d/invoice_ninja.conf
ADD start.sh /var/www/invoice-ninja/start.sh
RUN ln -s /etc/nginx/sites-available/invoice_ninja /etc/nginx/sites-enabled/invoice_ninja && \
    chown -R www-data:www-data /var/www/invoice-ninja

CMD ["bash", "start.sh"]
EXPOSE 80
