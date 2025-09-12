#!/bin/sh

set -e                            # Exit immediately if a command exits with a non-zero status
set -u                            # Treat unset variables as an error and exit immediately

if [ -z "${DOMAIN_NAME}" ] || [ -z "${PMA_ACCESSIBLE}" ] || [ -z "${WP_ADMIN_ACCESSIBLE}" ]; then   # Check if DOMAIN_NAME or PMA_ACCESSIBLE are unset or empty
    echo "PLEASE SET DOMAIN_NAME PMA_ACCESSIBLE WP_ADMIN_ACCESSIBLE ENVIRONMENT VARIABLE"
    exit 1                      # Exit with error if variables are not set
fi

echo "Applying envsubst to nginx configuration template"
envsubst '${DOMAIN_NAME} ${PMA_ACCESSIBLE} ${WP_ADMIN_ACCESSIBLE}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf   # Substitute environment variables in the nginx config template and write to the config file

exec "$@"                        # Replace the shell with the command passed as arguments to the script