#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "SCRIPT START: WordPress setup script is running."

# --- Step 1: Wait for MariaDB ---
echo "Waiting for MariaDB at host 'mariadb'..."
# Add a timeout to avoid waiting indefinitely
timeout=60
while ! mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
    timeout=$((timeout-1))
    if [ $timeout -eq 0 ]; then
        echo "ERROR: Could not connect to MariaDB after 60 seconds. Aborting."
        exit 1
    fi
    echo -n "."
    sleep 1
done
echo "SUCCESS: MariaDB is ready."

# --- Step 2: Check the target directory ---
TARGET_DIR="/var/www/html"
echo "Changing directory to ${TARGET_DIR}..."
if [ ! -d "${TARGET_DIR}" ]; then
    echo "ERROR: Directory ${TARGET_DIR} does not exist. Check your Dockerfile 'mkdir' command."
    exit 1
fi
cd "${TARGET_DIR}"
echo "Current directory: $(pwd)"

# --- Step 3: Check volume status ---
echo "Checking content of ${TARGET_DIR}..."
ls -la

# --- Step 4: Installation condition ---
# The most reliable condition is to check for a key file like wp-config.php
if [ -f "wp-config.php" ]; then
    echo "INFO: WordPress is already installed (wp-config.php found)."
else
    echo "INFO: WordPress not found. Starting installation..."

    # --- Download ---
    echo "Downloading WordPress core..."
    wp core download --allow-root
    echo "SUCCESS: WordPress downloaded."

    # --- DB configuration ---
    echo "Creating wp-config.php..."
    wp config create --dbname="${MYSQL_DATABASE}" \
                     --dbuser="${MYSQL_USER}" \
                     --dbpass="${MYSQL_PASSWORD}" \
                     --dbhost=mariadb \
                     --allow-root
    echo "SUCCESS: wp-config.php created."

    # --- Core installation ---
    echo "Installing WordPress core..."
    wp core install --url="${DOMAIN_NAME}" \
                    --title="${WP_TITLE}" \
                    --admin_user="${WP_ADMIN_USER}" \
                    --admin_password="${WP_ADMIN_PASSWORD}" \
                    --admin_email="${WP_ADMIN_EMAIL}" \
                    --allow-root
    echo "SUCCESS: WordPress core installed."

    # --- Create second user ---
    echo "Creating second user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
                   --role=author \
                   --user_pass="${WP_USER_PASSWORD}" \
                   --allow-root
    echo "SUCCESS: Second user created."

    echo "INFO: Full WordPress installation finished."
fi

# --- Step 5: Start PHP-FPM ---
echo "SCRIPT END: Handing over to PHP-FPM..."
# Start PHP-FPM in foreground to keep the container alive
exec /usr/sbin/php-fpm8.3 -F
