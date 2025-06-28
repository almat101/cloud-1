FROM certbot/certbot:latest

# Install Cloudflare plugin
RUN pip install certbot-dns-cloudflare
# for local develpoment
RUN apk add --no-cache openssl

# Copy entrypoint script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

# FROM alpine:3.21

# # Install certbot
# RUN apk update && \
#     apk add --no-cache python3 py3-pip certbot

# RUN pip3 install certbot-dns-cloudflare

# # Create necessary directories
# RUN mkdir -p /etc/letsencrypt /var/lib/letsencrypt

# # Set working directory
# WORKDIR /etc/letsencrypt

# COPY tools/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# # Set entrypoint to certbot
# ENTRYPOINT ["/entrypoint.sh"]

# # Default command
# CMD ["--help"]