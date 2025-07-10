# Cloud-1 Container Documentation

## Overview

This documentation covers the containerized architecture of the cloud-1 project, a multi-service web application stack built with Docker and Docker Compose. The stack includes WordPress, MariaDB, phpMyAdmin, Nginx, and automated SSL certificate management.

## Table of Contents

1. [Architecture](#architecture)
2. [Services Overview](#services-overview)
3. [Docker Images](#docker-images)
4. [Networking](#networking)
5. [Volume Management](#volume-management)
6. [SSL Certificate Management](#ssl-certificate-management)
7. [Service Configuration](#service-configuration)
8. [Deployment](#deployment)
9. [Monitoring and Health Checks](#monitoring-and-health-checks)
10. [Troubleshooting](#troubleshooting)

## Architecture

The cloud-1 application follows a microservices architecture with the following components:

```
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                ┌─────▼─────┐
                │   Nginx   │ (Port 80/443)
                │  Reverse  │
                │   Proxy   │
                └─────┬─────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
  ┌─────▼─────┐ ┌─────▼─────┐ ┌─────▼─────┐
  │WordPress  │ │phpMyAdmin │ │  Certbot  │
  │   (PHP)   │ │   (PHP)   │ │   (SSL)   │
  └─────┬─────┘ └─────┬─────┘ └───────────┘
        │             │
        └─────────────┼─────────────┘
                      │
                ┌─────▼─────┐
                │  MariaDB  │
                │ Database  │
                └───────────┘
```

## Services Overview

### Core Services

| Service | Purpose | Technology | Ports |
|---------|---------|------------|-------|
| **nginx** | Web server & reverse proxy | Alpine Linux + Nginx | 80, 443 |
| **wordpress** | Content management system | Alpine Linux + PHP-FPM + WordPress | 9000 |
| **mariadb** | Database server | Alpine Linux + MariaDB | 3306 |
| **phpmyadmin** | Database administration | Alpine Linux + PHP-FPM + phpMyAdmin | 9000 |
| **certbot** | SSL certificate management | Certbot + Cloudflare DNS | - |

### Service Dependencies

```yaml
# Dependency chain
certbot → nginx → wordpress → mariadb
certbot → nginx → phpmyadmin → mariadb
```

## Docker Images

### Base Images

All services use **Alpine Linux 3.21** as the base image for minimal footprint and security.

### Custom Image Build Process

#### Nginx Service

**Dockerfile**: [`srcs/requirements/nginx/Dockerfile`](srcs/requirements/nginx/Dockerfile)

```dockerfile
FROM alpine:3.21

# Create nginx user with fixed UIDs
RUN addgroup -S -g 101 nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

# Install nginx and dependencies
RUN apk update && \
    apk add --no-cache gettext curl nginx
```

**Key Features**:
- Template-based configuration with environment variable substitution
- SSL/TLS termination with Let's Encrypt certificates
- Reverse proxy for WordPress and phpMyAdmin
- Health check endpoint at custom location `/health`

#### WordPress Service

**Dockerfile**: [`srcs/requirements/wordpress/Dockerfile`](srcs/requirements/wordpress/Dockerfile)

```dockerfile
FROM alpine:3.21

# Install PHP 8.4 and extensions
RUN apk add --no-cache php84 php84-fpm php84-mysqli php84-pdo_mysql \
    php84-gd php84-xml php84-curl php84-iconv php84-json php84-mbstring

# Install WordPress and WP-CLI
RUN wget https://wordpress.org/wordpress-${WP_VERSION}.tar.gz
```

**Key Features**:
- PHP 8.4 with necessary extensions
- WordPress CLI for automated setup
- Database connection health checks
- Automated user creation and configuration

#### MariaDB Service

**Dockerfile**: [`srcs/requirements/mariadb/Dockerfile`](srcs/requirements/mariadb/Dockerfile)

```dockerfile
FROM alpine:3.21

# Install MariaDB
RUN apk add --no-cache mariadb mariadb-client
```

**Key Features**:
- Custom database and user initialization
- Persistent data storage
- Performance-optimized configuration
- Connection security settings

#### phpMyAdmin Service

**Dockerfile**: [`srcs/requirements/phpmyadmin/Dockerfile`](srcs/requirements/phpmyadmin/Dockerfile)

```dockerfile
FROM alpine:3.21

# Install PHP 8.4 and phpMyAdmin
RUN apk add --no-cache php84 php84-fpm php84-mysqli php84-session
```

**Key Features**:
- Secure configuration with environment variables
- Blowfish secret encryption
- Database connection management
- Access control integration

#### Certbot Service

**Dockerfile**: [`srcs/requirements/certbot/Dockerfile`](srcs/requirements/certbot/Dockerfile)

```dockerfile
FROM certbot/certbot:latest

# Install Cloudflare DNS plugin
RUN pip install certbot-dns-cloudflare
```

**Key Features**:
- Cloudflare DNS challenge support
- Automatic certificate renewal
- Self-signed certificates for local development
- Certificate validation and monitoring

## Networking

### Network Configuration

```yaml
networks:
  cloud-1:
    driver: bridge
```

### Service Communication

| From | To | Protocol | Port | Purpose |
|------|----|---------|----- |---------|
| nginx | wordpress | HTTP | 9000 | PHP-FPM requests |
| nginx | phpmyadmin | HTTP | 9000 | PHP-FPM requests |
| wordpress | mariadb | TCP | 3306 | Database queries |
| phpmyadmin | mariadb | TCP | 3306 | Database admin |

### External Access

- **HTTP**: Port 80 (redirects to HTTPS)
- **HTTPS**: Port 443 (main application access)
- **Health Check**: `https://domain.com/health`

## Volume Management

### Persistent Volumes

```yaml
volumes:
  wordpress:        # WordPress files and uploads
  mariadb_data:     # Database data persistence
  phpmyadmin:       # phpMyAdmin files
  certs:           # SSL certificates
```

### Volume Mappings

| Service | Volume | Container Path | Purpose |
|---------|--------|---------------|---------|
| nginx | wordpress | `/var/www/html` | WordPress files |
| nginx | phpmyadmin | `/var/www/phpmyadmin` | phpMyAdmin files |
| nginx | certs | `/etc/letsencrypt` | SSL certificates |
| wordpress | wordpress | `/var/www/html` | WordPress files |
| mariadb | mariadb_data | `/var/lib/mysql` | Database data |
| phpmyadmin | phpmyadmin | `/var/www/phpmyadmin` | phpMyAdmin files |
| certbot | certs | `/etc/letsencrypt` | Certificate storage |

## SSL Certificate Management

### Certificate Generation

The certbot service handles SSL certificate management with two modes:

#### Production Mode (Let's Encrypt)

```bash
# Automatic certificate generation for production domains
certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials /tmp/cloudflare.ini \
  --email "$EMAIL" \
  --agree-tos \
  --non-interactive \
  -d "$DOMAIN_NAME"
```

#### Development Mode (Self-Signed)

```bash
# Self-signed certificate for localhost/local development
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "/etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem" \
  -out "/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem"
```

### Certificate Renewal

Automated renewal is handled by the certbot service:

```bash
# Check and renew certificates if needed
certbot renew --dns-cloudflare --dns-cloudflare-credentials /tmp/cloudflare.ini --quiet
```

## Service Configuration

### Environment Variables

#### Core Configuration

```bash
# Domain and SSL
DOMAIN_NAME=cloud1.example.com
EMAIL=admin@example.com
CLOUDFLARE_API_TOKEN=your_api_token

# Database Configuration
MARIA_DB=mariadb
MARIA_DB_NAME=wordpress_db
MARIA_USER=wp_user
MARIA_PASSWORD=secure_password
MARIA_ROOT_PASSWORD=root_password

# WordPress Configuration
WP_TITLE="My WordPress Site"
WP_USER=editor
WP_PASSWORD=editor_password
WP_EMAIL=editor@example.com
WP_ROOT_USER=admin
WP_ROOT_PASSWORD=admin_password
WP_ROOT_EMAIL=admin@example.com

# Access Control
WP_ADMIN_ACCESSIBLE=true
PMA_ACCESSIBLE=true
BLOWFISH_SECRET=your_32_character_secret
```

### Service-Specific Configuration

#### Nginx Configuration

Template: [`srcs/requirements/nginx/conf/nginx.conf.template`](srcs/requirements/nginx/conf/nginx.conf.template)

**Key Features**:
- HTTP to HTTPS redirect
- WordPress admin IP restriction
- phpMyAdmin access control
- SSL/TLS security headers
- Health check endpoint

#### WordPress Configuration

Script: [`srcs/requirements/wordpress/tools/wp_config.sh`](srcs/requirements/wordpress/tools/wp_config.sh)

**Initialization Process**:
1. Wait for database connection
2. Create WordPress configuration
3. Install WordPress core
4. Create admin and editor users
5. Configure site URLs for production

#### MariaDB Configuration

Script: [`srcs/requirements/mariadb/tools/maria.sh`](srcs/requirements/mariadb/tools/maria.sh)

**Initialization Process**:
1. Start MariaDB in safe mode
2. Create application database
3. Create application user
4. Grant necessary privileges
5. Secure root account

## Deployment

### Docker Compose Deployment

```bash
# Build and start all services
docker compose up -d --build

# View service status
docker compose ps

# View logs
docker compose logs -f [service_name]

# Stop all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

### Service Dependencies

Services start in the following order:
1. **mariadb** (database foundation)
2. **certbot** (SSL certificate generation)
3. **wordpress** & **phpmyadmin** (application services)
4. **nginx** (reverse proxy and web server)

### Health Checks

Each service includes health check configuration:

```yaml
# Example health check
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 5s
```

## Monitoring and Health Checks

### Service Health Monitoring

| Service | Health Check | Command |
|---------|--------------|---------|
| nginx | HTTP endpoint | `curl -f http://localhost/health` |
| wordpress | Port availability | `nc -z localhost 9000` |
| mariadb | Database ping | `mariadb-admin ping` |
| phpmyadmin | Port availability | `nc -z localhost 9000` |

### Monitoring Commands

```bash
# Check service status
docker compose ps

# View resource usage
docker stats

# Check service logs
docker compose logs -f nginx
docker compose logs -f wordpress
docker compose logs -f mariadb

# Test connectivity
docker compose exec nginx curl -f http://localhost/health
docker compose exec wordpress nc -z mariadb 3306
```

### Performance Monitoring

```bash
# Monitor container resource usage
docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 
# Check disk usage
docker system df

# Monitor logs in real-time
docker compose logs -f --tail=100
```

## Troubleshooting

### Common Issues

#### 1. SSL Certificate Issues

```bash
# Check certificate status
docker compose exec certbot ls -la /etc/letsencrypt/live/

# Regenerate certificates
docker compose exec certbot certbot renew --force-renewal

# Check certificate validity
openssl x509 -in /path/to/cert.pem -text -noout
```

#### 2. Database Connection Issues

```bash
# Test database connectivity
docker compose exec wordpress nc -z mariadb 3306

# Check database logs
docker compose logs mariadb

# Verify database credentials
docker compose exec mariadb mariadb -u root -p -e "SHOW DATABASES;"
```

#### 3. WordPress Configuration Issues

```bash
# Check WordPress installation
docker compose exec wordpress wp --allow-root core is-installed

# Verify WordPress configuration
docker compose exec wordpress wp --allow-root config list

# Check file permissions
docker compose exec wordpress ls -la /var/www/html/
```

#### 4. Nginx Configuration Issues

```bash
# Test nginx configuration
docker compose exec nginx nginx -t

# Check nginx access logs
docker compose exec nginx tail -f /var/log/nginx/access.log

# Verify proxy configuration
docker compose exec nginx curl -H "Host: example.com" http://localhost/
```

### Debug Commands

```bash
# Access service shell
docker compose exec nginx sh
docker compose exec wordpress sh
docker compose exec mariadb sh

# Check environment variables
docker compose exec nginx env
docker compose exec wordpress env

# Verify network connectivity
docker compose exec nginx ping wordpress
docker compose exec wordpress ping mariadb
```

### Log Analysis

```bash
# Aggregate logs from all services
docker compose logs --timestamps

# Filter logs by service
docker compose logs nginx | grep ERROR
docker compose logs wordpress | grep PHP

# Monitor logs in real-time
docker compose logs -f --tail=50
```

## Security Considerations

### Access Control

1. **WordPress Admin Access**:
   - IP-based restrictions in nginx configuration
   - Environment variable control: `WP_ADMIN_ACCESSIBLE`

2. **phpMyAdmin Access**:
   - Environment variable control: `PMA_ACCESSIBLE`
   - Secure blowfish secret configuration

3. **Database Security**:
   - Dedicated non-root database user
   - Network isolation within Docker network
   - Secure password management

### File Permissions

```bash
# WordPress file permissions
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
```

### SSL/TLS Security

```nginx
# Security headers in nginx configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
ssl_prefer_server_ciphers off;
```

This comprehensive container documentation provides detailed information about the cloud-1 application's containerized architecture, deployment, and maintenance procedures.