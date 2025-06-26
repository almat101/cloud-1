#!/bin/sh

set -e
set -u
set -x

# Check required environment variables
if [ -z "${DOMAIN_NAME}" ] || [ -z "${PMA_ACCESSIBLE}" ]; then
    echo "PLEASE SET DOMAIN_NAME AND PMA_ACCESSIBLE ENVIRONMENT VARIABLES"
    exit 1
fi

# Generate SSL configuration based on SSL_ENABLED
if [ "${SSL_ENABLED}" = "true" ]; then
    echo "SSL is enabled. Generating certificates and configuration..."
    mkdir -p /etc/nginx/ssl
    
    # Generate certificates
    openssl req -x509 -nodes -out /etc/nginx/ssl/cert.pem \
            -keyout /etc/nginx/ssl/key.pem \
            -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"
            
    # Set SSL variables for template
    export SSL_SUFFIX=" ssl"
    export SSL_CONFIG="ssl_certificate /etc/nginx/ssl/cert.pem; ssl_certificate_key /etc/nginx/ssl/key.pem; ssl_protocols TLSv1.2 TLSv1.3;"
    #TODO remove export PORT=443  # Automatically switch to SSL port
else
    # echo "SSL is disabled. Using standard HTTP configuration."
    export SSL_SUFFIX=""
    export SSL_CONFIG=""
    #TODO remove export PORT=80  # Use provided PORT or default to 80
fi

# Apply environment variables to Nginx config
echo "Applying envsubst to nginx configuration template"
envsubst '${DOMAIN_NAME} ${PMA_ACCESSIBLE} ${PORT} ${SSL_SUFFIX} ${SSL_CONFIG}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"

# #!/bin/sh

# set -e                            # Exit immediately if a command exits with a non-zero status
# set -u                            # Treat unset variables as an error and exit immediately
# set -x
# if [ -z "${DOMAIN_NAME}" ] || [ -z "${PMA_ACCESSIBLE}" ] || [ -z "${PORT}" ] || [ -z "${SSL_ENABLED} "]; then   # Check if DOMAIN_NAME or PMA_ACCESSIBLE are unset or empty
#     echo "PLEASE SET DOMAIN_NAME, PMA_ACCESSIBLE, PORT and SSL_ENABLED ENVIROMENT VARIABLE"
#     exit 1                      # Exit with error if variables are not set
# fi

# echo "Applying envsubst to nginx configuration template"
# envsubst '${DOMAIN_NAME} ${PMA_ACCESSIBLE} ${PORT} ${SSL_ENABLED}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf   # Substitute environment variables in the nginx config template and write to the config file

# # if [ -z "${PORT}" ]; then
# #     echo "PLEASE SET THE PORTS ENVIRONMENT VARIABLE"
# #     exit 1
# # fi

# if [ "${PORT}" = "443" ] && [ "${SSL_ENABLED}" = "true" ]; then
#     mkdir -p /etc/nginx/ssl
#     echo "Using ssl port ${PORT} and DOMAIN NAME ${DOMAIN_NAME}"
#     echo "Create a self-signed SSL certificate"
#     openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"
# elif [ "${PORT}" = "80"]; then
#     echo "Using http port 80 and DOMAIN NAME "${DOMAIN_NAME}""
# fi


# exec "$@"                        # Replace the shell with the command passed as arguments to the script