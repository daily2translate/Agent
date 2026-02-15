FROM wordpress:latest

# Install additional PHP extensions for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    wget \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && rm -rf /var/lib/apt/lists/*

# Install PG4WP plugin for PostgreSQL support from GitHub (v3 branch)
RUN wget -q -O /tmp/pg4wp.zip https://github.com/PostgreSQL-For-Wordpress/postgresql-for-wordpress/archive/refs/heads/v3.zip \
    && unzip -q /tmp/pg4wp.zip -d /tmp/ \
    && mv /tmp/postgresql-for-wordpress-v3 /usr/src/wordpress/wp-content/plugins/pg4wp \
    && rm /tmp/pg4wp.zip

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port (Render will use PORT env var)
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
