FROM debian:12.11-slim AS nginx

# Updatesm nginx and openssl installs
RUN apt update && apt upgrade -y
RUN apt install nginx openssl -y
RUN rm -rf /var/lib/apt/lists/*

# SSL certificate creation
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=mgouraud/CN=mgouraud.42.fr"

# Copy conf
COPY ./conf/nginx.conf /etc/nginx/sites-available/default

# Launch nginx in foreground to keep container running
CMD ["nginx", "-g", "daemon off;"]
