#!/bin/bash

# n8n with Cloudflare Tunnel Startup Script
# This script starts n8n and creates a Cloudflare Tunnel for external access

set -e

echo "🚀 Starting n8n Automation Environment..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Generate encryption key if not set
if [ -z "$N8N_ENCRYPTION_KEY" ]; then
    ENCRYPTION_KEY=$(openssl rand -base64 32)
    echo "N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY" >> .env
    export N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
    echo "✅ Generated encryption key"
fi

# Generate password if not set
if [ -z "$N8N_BASIC_AUTH_PASSWORD" ]; then
    PASSWORD=$(openssl rand -base64 12)
    echo "N8N_BASIC_AUTH_PASSWORD=$PASSWORD" >> .env
    export N8N_BASIC_AUTH_PASSWORD=$PASSWORD
    echo "✅ Generated admin password: $PASSWORD"
fi

# Create log directory
mkdir -p logs

# Start n8n in background
echo "🔧 Starting n8n on port ${N8N_PORT}..."
npm start > logs/n8n.log 2>&1 &
N8N_PID=$!
echo $N8N_PID > logs/n8n.pid
echo "✅ n8n started (PID: $N8N_PID)"

# Wait for n8n to be ready
echo "⏳ Waiting for n8n to start..."
sleep 10

# Start Cloudflare Tunnel
echo "🌐 Starting Cloudflare Tunnel..."
cloudflared tunnel --url http://localhost:${N8N_PORT} > logs/cloudflare.log 2>&1 &
TUNNEL_PID=$!
echo $TUNNEL_PID > logs/cloudflare.pid
echo "✅ Cloudflare Tunnel started (PID: $TUNNEL_PID)"

# Wait for tunnel URL
echo "⏳ Waiting for tunnel URL..."
sleep 5

# Extract tunnel URL from logs
TUNNEL_URL=$(grep -oP 'https://.*\.trycloudflare\.com' logs/cloudflare.log | head -1)

if [ -n "$TUNNEL_URL" ]; then
    echo ""
    echo "=========================================="
    echo "✅ n8n is now accessible at:"
    echo "   $TUNNEL_URL"
    echo ""
    echo "📝 Login credentials:"
    echo "   Username: ${N8N_BASIC_AUTH_USER}"
    echo "   Password: ${N8N_BASIC_AUTH_PASSWORD}"
    echo ""
    echo "=========================================="
    echo ""
    echo "Tunnel URL: $TUNNEL_URL" > logs/tunnel-url.txt
else
    echo "⚠️  Could not extract tunnel URL. Check logs/cloudflare.log"
fi

echo "📊 Logs:"
echo "   n8n:        tail -f logs/n8n.log"
echo "   Cloudflare: tail -f logs/cloudflare.log"
echo ""
echo "🛑 To stop: bash stop.sh"
