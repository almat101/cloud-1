FROM alpine:3.21

# Install MariaDB
RUN apk update && \
    apk add --no-cache mariadb mariadb-client net-tools && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

#Copy configuration file
#Note: Alpine uses a different path for MariaDB config
# COPY conf/50-server.cnf /etc/my.cnf.d/50-server.cnf
COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

# Copy and make the startup script executable
COPY tools/maria.sh /usr/local/bin/maria.sh
RUN chmod +x /usr/local/bin/maria.sh

# Initialize MariaDB data directory
RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql && \
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

# Run the startup script
CMD ["/usr/local/bin/maria.sh"]