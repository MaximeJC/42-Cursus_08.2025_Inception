FROM debian:12.11-slim AS mariadb

# Updates and mariadb installs
RUN apt update && apt upgrade -y
RUN apt-get install -y mariadb-server procps
RUN rm -rf /var/lib/apt/lists/*

# Create dir for db files
RUN mkdir -p /etc/mysql/mariadb.conf.d/
COPY ./conf/mariadb.cnf /etc/mysql/mariadb.conf.d/60-custom.cnf

# Copy conf script
COPY ./tools/mariadb_setup.sh /usr/local/bin/mariadb_setup.sh
RUN chmod +x /usr/local/bin/mariadb_setup.sh

# Expose port
EXPOSE 3306

# Execute script at container launch
ENTRYPOINT ["/usr/local/bin/mariadb_setup.sh"]

