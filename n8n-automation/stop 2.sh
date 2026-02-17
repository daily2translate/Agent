#!/bin/bash

# Stop n8n and Cloudflare Tunnel

echo "🛑 Stopping n8n Automation Environment..."

# Stop n8n
if [ -f logs/n8n.pid ]; then
    N8N_PID=$(cat logs/n8n.pid)
    if kill -0 $N8N_PID 2>/dev/null; then
        kill $N8N_PID
        echo "✅ Stopped n8n (PID: $N8N_PID)"
    fi
    rm logs/n8n.pid
fi

# Stop Cloudflare Tunnel
if [ -f logs/cloudflare.pid ]; then
    TUNNEL_PID=$(cat logs/cloudflare.pid)
    if kill -0 $TUNNEL_PID 2>/dev/null; then
        kill $TUNNEL_PID
        echo "✅ Stopped Cloudflare Tunnel (PID: $TUNNEL_PID)"
    fi
    rm logs/cloudflare.pid
fi

echo "✅ All services stopped"
