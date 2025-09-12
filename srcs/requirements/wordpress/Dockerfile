FROM alpine:3.21

# Define wp version
ARG WP_VERSION=6.8.1

# For PHP 8.4
RUN apk add --no-cache netcat-openbsd php84-phar mariadb-client wget curl vim unzip git php84 php84-fpm php84-common php84-session php84-iconv php84-gd php84-curl php84-xml php84-mysqli php84-imap php84-pdo php84-pdo_mysql php84-soap php84-posix php84-gettext php84-ldap php84-ctype php84-dom php84-simplexml

# Create nginx user with fixed IDs (matching your nginx container)
RUN addgroup -S -g 101 nginx && \
    adduser -S -D -u 101 -h /var/www -s /sbin/nologin -G nginx nginx

# Avoid ERROR: failed to open error_log (/var/log/php84/error.log): Permission denied (13)
RUN mkdir -p /var/log/php84 && \
    chown -R nginx:nginx /var/log/php84 && \
    chmod 755 /var/log/php84

# Create the frontend directory for wp files   
RUN mkdir -p /var/www/html && \
    chown -R nginx:nginx /var/www/html && \
    chmod 755 /var/www/html

# Copy wordpress conf in alpine linux folder
COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

# Copy local assets
COPY assets/aws.jpg var/www/html/tmp/aws.jpg

# Download, extract WordPress and Fix ownership of all wp files
RUN wget https://wordpress.org/wordpress-${WP_VERSION}.tar.gz && \
    tar -xzvf wordpress-${WP_VERSION}.tar.gz -C /var/www/html --strip-components=1 && \
    rm wordpress-${WP_VERSION}.tar.gz && \
    chown -R nginx:nginx /var/www/html

# Create symlink from php84 to php
RUN ln -sf /usr/bin/php84 /usr/bin/php

# Download wp-cli to manage WordPress
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Copy script
COPY tools/wp_config.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wp_config.sh

# Switch user from root to nginx
USER nginx

CMD ["/usr/local/bin/wp_config.sh"]