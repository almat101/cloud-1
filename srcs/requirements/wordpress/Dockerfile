FROM alpine:3.21

# For PHP 8.4
RUN apk add --no-cache netcat-openbsd php84-phar mariadb-client wget curl vim unzip git php84 php84-fpm php84-common php84-session php84-iconv php84-gd php84-curl php84-xml php84-mysqli php84-imap php84-pdo php84-pdo_mysql php84-soap php84-posix php84-gettext php84-ldap php84-ctype php84-dom php84-simplexml

# Create web directory with appropriate ownership
RUN mkdir -p /var/www/html && \
    chown -R nobody:nobody /var/www/html

# Copy wordpress conf in alpine linux folder
COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

# Download, extract WordPress and Fix ownership of all wp files
RUN wget https://wordpress.org/wordpress-6.8.tar.gz && \
    tar -xzvf wordpress-6.8.tar.gz -C /var/www/html --strip-components=1 && \
    rm wordpress-6.8.tar.gz && \
    chown -R nobody:nobody /var/www/html

# Create symlink from php84 to php
RUN ln -sf /usr/bin/php84 /usr/bin/php

# Download wp-cli to manage WordPress
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Copy script
COPY tools/wp_config.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wp_config.sh

CMD ["/usr/local/bin/wp_config.sh"]