FROM alpine:3.21

# Create nginx user and group with fixed IDs like official nginx image
RUN addgroup -S -g 101 nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

RUN apk update && apk add --no-cache wget curl nginx && \
    chown -R nginx:nginx /etc/nginx

COPY --chown=nginx:nginx conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]