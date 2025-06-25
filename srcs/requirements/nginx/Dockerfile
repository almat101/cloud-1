FROM alpine:3.21

# Create nginx user and group with fixed IDs like official nginx image
RUN addgroup -S -g 101 nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

RUN apk update && \
    apk add --no-cache gettext curl nginx && \
    # Create basic directories
    mkdir -p /var/run/nginx && \
    mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/run/nginx /var/log/nginx && \
    # Create symlinks for logs to stdout/stderr 
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY --chown=nginx:nginx conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY --chown=nginx:nginx tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]