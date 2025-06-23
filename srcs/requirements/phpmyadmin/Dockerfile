FROM alpine:3.21

# Define phpmyadmin version
ARG PMA_VERSION=5.2.2

RUN apk update && \
    apk add --no-cache vim curl wget php84 php84-fpm php84-session php84-mysqli \
    php84-mbstring php84-json php84-zip php84-gd php84-xml php84-curl php84-ctype php84-iconv \
    php84-openssl php84-tokenizer php84-phar php84-fileinfo php84-sodium unzip

# Create nginx user with fixed IDs (matching your nginx container)
RUN addgroup -S -g 101 nginx && \
    adduser -S -D -u 101 -h /var/www -s /sbin/nologin -G nginx nginx

# Avoid ERROR: failed to open error_log (/var/log/php84/error.log): Permission denied (13)
RUN mkdir -p /var/log/php84 && \
    chown -R nginx:nginx /var/log/php84 && \
    chmod 755 /var/log/php84

RUN mkdir -p /var/www/phpmyadmin && \
    chown -R nginx:nginx /var/www/phpmyadmin    

# Download and extract phpMyAdmin
RUN wget "https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip" && \
    unzip phpMyAdmin-${PMA_VERSION}-all-languages.zip && \
    mv phpMyAdmin-${PMA_VERSION}-all-languages/* /var/www/phpmyadmin/ && \
    rm -rf phpMyAdmin-${PMA_VERSION}-all-languages.zip phpMyAdmin-${PMA_VERSION}-all-languages && \
    chown -R nobody:nobody /var/www/phpmyadmin

# Create php-fpm configuration directory and copy config
RUN mkdir -p /etc/php84/php-fpm.d
COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

# Create config.inc.php file
COPY conf/config.inc.php /var/www/phpmyadmin/

# Create symlink from php84 to php
RUN ln -sf /usr/bin/php84 /usr/bin/php

# Swith user from root to nginx
USER nginx

CMD ["php-fpm84", "-F"]