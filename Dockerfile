FROM wordpress:latest

# Install additional PHP extensions for PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && rm -rf /var/lib/apt/lists/*

# Install PG4WP plugin for PostgreSQL support
RUN curl -L https://downloads.wordpress.org/plugin/pg4wp.latest.zip -o /tmp/pg4wp.zip \
    && unzip /tmp/pg4wp.zip -d /usr/src/wordpress/wp-content/plugins/ \
    && rm /tmp/pg4wp.zip

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port (Render will use PORT env var)
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
