#!/bin/sh

echo "Waiting for mariadb..."
until mariadb -h "$MARIA_DB" -u "$MARIA_USER" -p"$MARIA_PASSWORD" "$MARIA_DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for database connection..."
  sleep 2
done
echo "Database connection established!"

cd /var/www/html

# Create a new wp-config.php file via wp-cli
if ! test -f "/var/www/html/wp-config.php"; then
	echo "Create a new wp-config.php file via wp-cli"
	wp config create	--allow-root \
					--dbname=$MARIA_DB_NAME \
					--dbuser=$MARIA_USER \
					--dbpass=$MARIA_PASSWORD \
					--dbhost=mariadb:3306 --path='/var/www/html'

	# Install wordpress via wp-cli(created also the admin user )
	echo "Install wordpress via wp-cli(created also the admin user)"
	wp core install	--url=$DOMAIN_NAME \
				--title=$WP_TITLE \
				--admin_user=$WP_ROOT_USER \
				--admin_password=$WP_ROOT_PASSWORD \
				--admin_email=$WP_ROOT_EMAIL \
				--skip-email --allow-root \
				--path='/var/www/html'

	# Create a new user as an author user (second user)
	echo "Create a new user as an author user (second user)"
	wp user create	$WP_USER \
				$WP_EMAIL \
				--role=author \
				--user_pass=$WP_PASSWORD \
				--allow-root \
				--path='/var/www/html'

	# Insert Redis configuration before the "Happy publishing" line
	# this line is before require_once(ABSPATH . 'wp-settings.php'); for making sure that the Redis configuration is loaded before the WordPress object cache is initialized.
	# echo "Inserting Redis configuration to wp-config.php"
	# sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \\
	# // Redis Object Cache Configuration \n\
	# define('WP_REDIS_HOST', 'redis'); \n\
	# define('WP_REDIS_PORT', 6379); \n\
	# define('WP_CACHE', true); \n" /var/www/html/wp-config.php

	# Install the Redis plugin
	# wp plugin install redis-cache --activate --allow-root

    # # Enable Redis cache via WP-CLI
    # wp redis enable --allow-root

    # # Check Redis connection status
    # wp redis status --allow-root

    # # Configure Redis cache settings
    # wp config set WP_REDIS_HOST "redis" --allow-root
	# # this line ensure that WordPress connects to the Redis container within the same Docker Compose network, making inter-container communication possible.
    # wp config set WP_REDIS_PORT "6379" --allow-root
	# # redis standard port
    # wp config set WP_REDIS_DATABASE "15" --allow-root
	# # database 15 is used for object cache
	# wp config set WP_REDIS_MAXTTL "86400" --allow-root
	# 24 hours

	#gives the right permissions to the files and directory for wordpress,nginx and redis
	# find /var/www/html -type d -exec chmod 755 {} \;
	# find /var/www/html -type f -exec chmod 644 {} \;
	# chown -R www-data:www-data /var/www/html

	# Create the uploads directory for the FTP user
	# echo "Create the uploads directory for the FTP user"
	# # echo $FTP_USER
	# id -u $FTP_USER &>/dev/null || useradd -m $FTP_USER
	# mkdir -p /var/www/html/uploads
	# chown -R $FTP_USER:www-data /var/www/html/uploads
	# chmod 775 /var/www/html/uploads

	echo "wp-config.php created!"
else
	echo "wp-config.php already exist!"
fi

echo "Execute the cgi"
/usr/sbin/php-fpm84 -F