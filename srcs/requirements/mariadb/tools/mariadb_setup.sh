#!/bin/bash
set -e

# This checks if the data directory is already initialized
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "INFO: Database already initialized. Skipping setup."
else
    echo "INFO: Database not found. Starting initial setup..."

    # Initialize MariaDB data directory & start it temporarily
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    mysqld_safe --datadir=/var/lib/mysql &

    # Wait for MariaDB to be ready
    until mysqladmin ping -h localhost --silent; do
        echo "Waiting for MariaDB service to start..."
        sleep 1
    done

    # Execute initial setup SQL commands
    mysql -u root -e "
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        DELETE FROM mysql.user WHERE User='';
        DROP DATABASE IF EXISTS test;
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
    "

    echo "SUCCESS: Initial database setup complete."

    # Shut down the temporary server using the new password
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait
fi

# Restart MariaDB in the foreground to keep the container running
echo "Starting MariaDB in foreground mode..."
exec mysqld_safe --datadir=/var/lib/mysql --user=mysql
