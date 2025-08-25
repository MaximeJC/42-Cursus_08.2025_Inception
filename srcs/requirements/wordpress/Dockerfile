FROM debian:12.11-slim AS wordpress

# Updates and php installs
RUN apt update && apt upgrade -y
RUN apt install -y apt-transport-https lsb-release ca-certificates wget
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
RUN apt update
RUN apt-get install -y php7.4-fpm
RUN apt-get install -y php7.4-mysql
RUN apt-get install -y php7.4-redis
RUN apt-get install -y curl
# RUN apt-get install -y wget
RUN apt-get install -y mariadb-client
RUN rm -rf /var/lib/apt/lists/*

# Get wordpress CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create dir for wp files
RUN mkdir -p /var/www/html
RUN mkdir -p /run/php

# Make php-fpm listen on port 9000 to communicate with nginx container
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf

# Copy conf script
COPY ./tools/wordpress_setup.sh /usr/local/bin/wordpress_setup.sh
RUN chmod +x /usr/local/bin/wordpress_setup.sh

# Execute script at container launch
ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]
