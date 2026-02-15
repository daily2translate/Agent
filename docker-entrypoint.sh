#!/bin/bash
set -e

# Configure Apache to listen on Render's PORT (default to 80 if not set)
export APACHE_PORT=${PORT:-80}

# Update Apache ports configuration
sed -i "s/Listen 80/Listen ${APACHE_PORT}/g" /etc/apache2/ports.conf
sed -i "s/:80/:${APACHE_PORT}/g" /etc/apache2/sites-available/000-default.conf

echo "Apache configured to listen on port ${APACHE_PORT}"

# Execute the original WordPress entrypoint
exec docker-entrypoint.sh "$@"
