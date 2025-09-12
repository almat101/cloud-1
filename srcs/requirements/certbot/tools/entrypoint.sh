#!/bin/sh

set -eu

# Check required environment variables
for var in DOMAIN_NAME EMAIL CLOUDFLARE_API_TOKEN; do
  eval "value=\$$var"
  if [ -z "$value" ]; then
    echo "ERROR: Environment variable $var is not set."
    exit 1
  fi
done

echo "=== Using Cloudflare DNS Challenge ==="
echo "Domain: $DOMAIN_NAME"
echo "Email: $EMAIL"


# Check if this is for localhost/local development
if [ "$DOMAIN_NAME" = "localhost" ] || [ "$DOMAIN_NAME" = "127.0.0.1" ]; then
    echo "Local development detected - generating self-signed certificate"
    
    # Create directory if it doesn't exist
    mkdir -p "/etc/letsencrypt/live/$DOMAIN_NAME"
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem" \
        -out "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=Dev/CN=$DOMAIN_NAME"
    
    # Set proper permissions
    chmod 600 "/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem"
    chmod 644 "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem"
    
    echo "✓ Self-signed certificate generated for local development"
    
else
    echo "Production domain detected - using Let's Encrypt"
fi    

# Create credentials file using API token
cat > /tmp/cloudflare.ini << EOF
dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN}
EOF

chmod 600 /tmp/cloudflare.ini

# Check if certificate already exists
if [ -f "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem" ]; then
    echo "Certificate already exists for $DOMAIN_NAME"
    echo "Checking if renewal is needed..."
    
    certbot renew --dns-cloudflare --dns-cloudflare-credentials /tmp/cloudflare.ini --quiet
    
else
    echo "Generating new certificate for $DOMAIN_NAME using DNS challenge..."
    
    #Generate certificate using DNS challenge
    # certbot certonly \
    #     --dns-cloudflare \
    #     --dns-cloudflare-credentials /tmp/cloudflare.ini \
    #     --email "$EMAIL" \
    #     --agree-tos \
    #     --no-eff-email \
    #     --non-interactive \
    #     -d "$DOMAIN_NAME"
        
    # #TODO Add --staging flag for testing this is the safe approach to avoid rate limiting and generate fake certificates
    certbot certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials /tmp/cloudflare.ini \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        --non-interactive \
        --staging \
        -d "$DOMAIN_NAME"
    
    if [ $? -eq 0 ]; then
        echo "✓ Certificate generated successfully!"
        ls -la "/etc/letsencrypt/live/$DOMAIN_NAME/"
        
        # Create SSL config file for nginx
        cat > /etc/letsencrypt/ssl.conf << 'EOF'
# SSL configuration is now available
# This file indicates certificates are ready
EOF
        
    else
        echo "✗ Certificate generation failed!"
        exit 1
    fi
fi

echo "=== Certificate process completed ==="