#!/bin/sh

echo "Waiting for mariadb..."
until mariadb -h "$MARIA_DB" -u "$MARIA_USER" -p"$MARIA_PASSWORD" "$MARIA_DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for database connection..."
  sleep 2
done
echo "Database connection established!"

cd /var/www/html

# #This lines is required if I dont use cloudeflared tunnel
# echo "Giving permission to files"
# find /var/www/html -type d -exec chmod 755 {} \;
# find /var/www/html -type f -exec chmod 644 {} \;

if [ ! -f /var/www/html/wp-config-sample.php ]; then
	echo "WordPress not found, downloading..."
	wget https://wordpress.org/wordpress-${WP_VERSION}.tar.gz && \
	tar -xzvf wordpress-${WP_VERSION}.tar.gz -C /var/www/html --strip-components=1 && \
    rm wordpress-${WP_VERSION}.tar.gz && \
    chown -R nginx:nginx /var/www/html
fi

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

    # Check if AWS image exists and create appropriate post
    if test -f "/var/www/html/tmp/aws.jpg"; then
        echo "AWS image found, creating post with background image..."
        
        # Upload the image to WordPress media library
        IMAGE_ID=$(wp media import /var/www/html/tmp/aws.jpg --porcelain --allow-root)
        echo "Image uploaded with ID: $IMAGE_ID"
        
        # Get the attachment URL
        IMAGE_URL=$(wp eval "echo wp_get_attachment_url($IMAGE_ID);" --allow-root)
        echo "Image URL: $IMAGE_URL"
        
        # Install elementor and create post with image first, then text
        wp plugin install elementor --activate --allow-root
		echo "Creating post..."
        wp post create --post_title="Welcome!" \
            --post_content="<div style=\"text-align: center; margin-bottom: 30px;\"><img src=\"$IMAGE_URL\" alt=\"AWS Cloud Infrastructure\" style=\"max-width: 100%; height: auto; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);\"></div><div style=\"padding: 20px;\"><h2 style=\"margin: 0 0 15px 0; font-size: 2em; color: #333;\">🚀 Cloud-1 WordPress Stack</h2><p style=\"margin: 0 0 20px 0; font-size: 1.2em; color: #666;\">Deployed with Docker & Ansible!</p><ul style=\"margin: 20px 0; padding-left: 0; list-style-type: none;\"><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🐳 Containerized Stack</strong>: WordPress, MariaDB, phpMyAdmin, Nginx with Alpine Linux base</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🔐 Automated SSL</strong>: Let's Encrypt certificates with Cloudflare DNS challenge</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🚀 Multi-Environment</strong>: Separate dev/prod configurations with Ansible</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🔒 Security-First</strong>: Vault-encrypted secrets, access controls, security headers</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>⚡ Zero-Downtime</strong>: Health checks and graceful service management</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🗄️ Database Admin</strong>: phpMyAdmin for easy database management</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🛠️ WordPress CLI Integration</strong>: Automated WordPress setup and management</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🔧 Custom Content Management</strong>: Automated post creation with media upload support</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🏗️ Role-Based Deployment</strong>: Modular Ansible roles for automated infrastructure</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>📁 Persistent Storage</strong>: Organized volume management for data persistence</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🌐 Network Isolation</strong>: Custom Docker networking with service communication</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>⚙️ Environment Templating</strong>: Dynamic configuration from Ansible Vault secrets</li></ul></div>" \
            --post_status=publish --allow-root
        
        echo "Post created with AWS image!"
    else
        echo "AWS image not found, creating simple post..."
        wp plugin install elementor --activate --allow-root
        wp post create --post_title="Welcome!" \
            --post_content="<div style=\"padding: 20px;\"><h2 style=\"margin: 0 0 15px 0; font-size: 2em; color: #333;\">🚀 Cloud-1 WordPress Stack</h2><p style=\"margin: 0 0 20px 0; font-size: 1.2em; color: #666;\">Deployed with Docker & Ansible!</p><ul style=\"margin: 20px 0; padding-left: 0; list-style-type: none;\"><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🐳 Containerized Stack</strong>: WordPress, MariaDB, phpMyAdmin, Nginx with Alpine Linux base</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🔐 Automated SSL</strong>: Let's Encrypt certificates with Cloudflare DNS challenge</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🚀 Multi-Environment</strong>: Separate dev/prod configurations with Ansible</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🔒 Security-First</strong>: Vault-encrypted secrets, access controls, security headers</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>⚡ Zero-Downtime</strong>: Health checks and graceful service management</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🗄️ Database Admin</strong>: phpMyAdmin for easy database management</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🛠️ WordPress CLI Integration</strong>: Automated WordPress setup and management</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🔧 Custom Content Management</strong>: Automated post creation with media upload support</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🏗️ Role-Based Deployment</strong>: Modular Ansible roles for automated infrastructure</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>📁 Persistent Storage</strong>: Organized volume management for data persistence</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>🌐 Network Isolation</strong>: Custom Docker networking with service communication</li><li style=\"margin: 10px 0; padding: 8px; background: #f8f9fa; border-left: 4px solid #007cba;\"><strong>⚙️ Environment Templating</strong>: Dynamic configuration from Ansible Vault secrets</li></ul></div>" \
            --post_status=publish --allow-root
    fi	
	echo "wp-config.php created!"
else
	echo "wp-config.php already exist!"
fi

echo "Execute the cgi"
/usr/sbin/php-fpm84 -F