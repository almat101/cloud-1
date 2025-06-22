FROM alpine:3.21

RUN apk update && \
    apk add --no-cache vim curl wget php84 php84-fpm php84-session php84-mysqli \
    php84-mbstring php84-json php84-zip php84-gd php84-xml php84-curl php84-ctype php84-iconv \
    php84-openssl php84-tokenizer php84-phar php84-fileinfo php84-sodium unzip

# Create web directory (no need to create a www user)
RUN mkdir -p /var/www/phpmyadmin

# Download and extract phpMyAdmin
RUN wget "https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.zip" && \
    unzip phpMyAdmin-5.2.2-all-languages.zip && \
    mv phpMyAdmin-5.2.2-all-languages/* /var/www/phpmyadmin/ && \
    rm -rf phpMyAdmin-5.2.2-all-languages.zip phpMyAdmin-5.2.2-all-languages && \
    chown -R nobody:nobody /var/www/phpmyadmin

# Create php-fpm configuration directory and copy config
RUN mkdir -p /etc/php84/php-fpm.d
COPY conf/www.conf /etc/php84/php-fpm.d/www.conf

# Create config.inc.php file
COPY conf/config.inc.php /var/www/phpmyadmin/

# Create symlink from php84 to php
RUN ln -sf /usr/bin/php84 /usr/bin/php

# Expose port for PHP-FPM
EXPOSE 9000

CMD ["php-fpm84", "-F"]