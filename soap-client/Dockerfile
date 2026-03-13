FROM nextcloud:32.0.6-fpm         
                                                                                                                                                 
  RUN apt-get update && \                                                                                                                        
      apt-get install -y --no-install-recommends \                                                                                               
        libxml2-dev libxslt1-dev && \                                                                                                            
      docker-php-ext-install xsl soap && \
      docker-php-ext-enable xsl soap && \
      apt-get purge -y libxml2-dev libxslt1-dev && \
      apt-get install -y --no-install-recommends \
        libxslt1.1 libxml2 && \
      rm -rf /var/lib/apt/lists/*

  ENTRYPOINT ["/entrypoint.sh"]
  CMD ["php-fpm"]
