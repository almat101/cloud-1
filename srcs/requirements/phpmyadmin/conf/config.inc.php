<?php

$blowfish_secret = getenv('BLOWFISH_SECRET');
# Check for blowfish secret
if (empty($blowfish_secret)) {
    die('BLOWFISH_SECRET environment variable is required, set it in .env!');
}
/**
 * phpMyAdmin configuration file
 * This is a central configuration file for phpMyAdmin settings
 */

/**
 * Server(s) configuration
 * Each $i entry represents a different database server that phpMyAdmin can connect to
 */
$i = 0;

/**
 * First server configuration
 */
$i++;

/**
 * Authentication settings
 * 'cookie' means users need to enter credentials to access phpMyAdmin
 * Other options include 'http' (HTTP Basic Auth), 'config' (credentials stored in this file), etc.
 */
$cfg['Servers'][$i]['auth_type'] = 'cookie';

/**
 * Connection settings for MariaDB server
 * 'mariadb' is the Docker service name defined in your docker-compose.yml
 * Port 3306 is the default MySQL/MariaDB port
 */
$cfg['Servers'][$i]['host'] = 'mariadb';
$cfg['Servers'][$i]['port'] = '3306';
$cfg['Servers'][$i]['compress'] = false;

/**
 * Disable the ability to connect without a password
 * Security best practice - force users to provide credentials
 */
$cfg['Servers'][$i]['AllowNoPassword'] = false;

/**
 * Advanced features configuration (disabled by default)
 * If you want to use phpMyAdmin storage features (like saved queries),
 * you'd need to set up the phpMyAdmin control database
 */
$cfg['Servers'][$i]['controlhost'] = '';
$cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = '';
$cfg['Servers'][$i]['controlpass'] = '';

/**
 * Directory settings for file uploads and exports
 * Empty means use the default temporary directory
 */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

/**
 * Blowfish secret - used for cookie authentication encryption
 * Generate a random 32-character string for better security
 * You can use: https://www.phpgangsta.de/en/php-tools/random-blowfish-secret-generator
 */
$cfg['blowfish_secret'] = $blowfish_secret;
// $cfg['blowfish_secret'] = '623aq7d9e78d0aDad4563fd8b9eed4b803b3b6ae605';


/**
 * Default language for the interface
 */
$cfg['DefaultLang'] = 'en';

/**
 * Default server to use when there are multiple
 * Since we only defined one server (index 1), we set it as default
 */
$cfg['ServerDefault'] = 1;

/**
 * Default display options
 * These make phpMyAdmin more user-friendly with larger page sizes
 */
$cfg['MaxRows'] = 50;
$cfg['ExecTimeLimit'] = 300;
$cfg['SendErrorReports'] = 'never';

/**
 * Theme settings
 * pmahomme is the default responsive theme
 */
$cfg['ThemeDefault'] = 'pmahomme';

/**
 * Security features
 * Recommended settings for production environments
 */
$cfg['LoginCookieValidity'] = 1440; // Login cookie validity in seconds (24 minutes)
$cfg['AllowThirdPartyFraming'] = false; // Prevent clickjacking attacks
$cfg['AllowArbitraryServer'] = false; // Don't allow users to enter custom server addresses

/**
 * Navigation settings
 * These control the appearance of the database navigation panel
 */
$cfg['NavigationTreeEnableGrouping'] = true;
$cfg['ShowStats'] = true;
$cfg['ShowPhpInfo'] = false; // Disable phpinfo() output for security

/**
 * Import/Export settings
 * Default settings for data import/export operations
 */
$cfg['Import']['charset'] = 'utf-8';
$cfg['Export']['charset'] = 'utf-8';
$cfg['Export']['method'] = 'quick';

// Set base URL to maintain correct paths
$cfg['PmaAbsoluteUri'] = 'http://' . $_SERVER['HTTP_HOST'] . '/phpmyadmin/';

?>