FROM nextcloud:fpm

RUN apt-get update && \
      apt-get install -y --no-install-recommends \
        libxml2-dev libxslt1-dev && \
      docker-php-ext-install xsl soap && \
      docker-php-ext-enable xsl soap && \
      apt-get purge -y libxml2-dev libxslt1-dev && \
      apt-get autoremove -y && \
      rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
