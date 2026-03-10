FROM nextcloud@sha256:0bf10863f8f3025c96a3f92fe3be57944895798fa6180bd3b99734af7f22071c                     

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
  
