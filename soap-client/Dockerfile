FROM nextcloud:fpm

RUN apt update; apt install libxml2-dev libxslt-dev -y;
RUN docker-php-ext-install xsl soap;
RUN docker-php-ext-enable xsl soap;

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]