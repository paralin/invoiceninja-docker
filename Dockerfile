FROM tutum/apache-php:latest
MAINTAINER Christian Stewart <kidovate@gmail.com>

# ubdate first
RUN apt-get update --assume-yes --quiet && apt-get install --assume-yes --quiet curl git wget apache2 php5 php5-curl php5-gd php5-imagick php-pear php5-imap php5-cli php5-cgi php5-mysql libapache2-mod-php5 php5-mcrypt

RUN curl -sL https://deb.nodesource.com/setup | sudo bash -

RUN apt-get install -y nodejs && apt-get clean && npm install -g bower grunt-cli

#get latest composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# configuration for invoice ninja
RUN php5enmod mcrypt && a2enmod rewrite

# add invoice ninja files
RUN rm -rf /app/
ADD invoice-ninja /var/www/invoice-ninja
RUN cd /var/www/invoice-ninja/ && rm composer.lock && composer install --prefer-source --no-dev && bower --allow-root install && chown -R www-data:www-data /var/www/invoice-ninja/

# define some environment variables
# database
ENV DATBASE_TYPE mysql
ENV DATBASE_HOST db
ENV DATBASE_NAME ninja
ENV DATBASE_USER ninja
ENV DATBASE_PASSWORD ninja

# application
ENV APPLICATION_URL http://www.invoiceninja.com/

# add files
ADD docker-apache.conf /etc/apache2/sites-enabled/000-default.conf
ADD database.php /var/www/invoice-ninja/app/config/database.php
ADD app.php /var/www/invoice-ninja/app/config/app.php
ADD run-invoice-ninja.sh /run-invoice-ninja.sh
ADD database-setup.sql /var/database-setup.sql

CMD ["/run-invoice-ninja.sh"]
EXPOSE 80
