FROM nginx:alpine

RUN apk update && apk add --no-cache wget curl vim sudo net-tools

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]