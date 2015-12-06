#!/bin/bash
set -e

# Patch the php5-fpm to source the config
source /etc/kube-invoice/config

sed -e "s/\$MARIADB_SERVICE_HOST/$MARIADB_SERVICE_HOST/g" -e "s/export //g" -e "s/\(.*\)=\(.*\)/env[\1]='\2'/" /etc/kube-invoice/config >> /etc/php5/fpm/pool.d/invoice_ninja.conf

php artisan migrate --seed
service php5-fpm restart
service nginx restart
sleep 1
tail -f /var/log/nginx/ininja*.log
