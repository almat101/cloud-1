#!/bin/sh

echo "Waiting for mariadb..."
until mariadb -h "$MARIA_DB" -u "$MARIA_USER" -p"$MARIA_PASSWORD" "$MARIA_DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for database connection..."
  sleep 2
done
echo "Database connection established!"

cd /var/www/html

#This lines is required if I dont use cloudeflared tunnel
echo "Giving permission to files"
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

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

	# After wp is installed, update the site URL settings
	if [ "$DOMAIN_NAME" = "cloud1.alematta.com" ]; then
		echo "Updating WordPress site URL settings..."
		wp option update siteurl "https://cloud1.alematta.com" --allow-root
		wp option update home "https://cloud1.alematta.com" --allow-root
	else
		echo "DOMAIN_NAME is set to '$DOMAIN_NAME', skipping site URL update."
	fi

	export LANG=C.UTF-8 && \
	wp theme install astra --activate --allow-root && \
	wp plugin install elementor --activate --allow-root && \
	wp post create --post_title="Welcome!" --post_content="<h2>🚀 Cloud-1 WordPress Stack</h2><p>Deployed with Docker & Ansible!</p>" --post_status=publish --allow-root
		
	echo "wp-config.php created!"
else
	echo "wp-config.php already exist!"
fi

echo "Execute the cgi"
/usr/sbin/php-fpm84 -F