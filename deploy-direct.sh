#!/bin/bash
set -e

echo "🚀 Deploying n8n directly (no Docker)..."

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install --frozen-lockfile

# Build the project
echo "🔨 Building n8n..."
NODE_OPTIONS="--max-old-space-size=8192" pnpm build

# Create .env file if it doesn't exist
if [ ! -f .env.production ]; then
    echo "📝 Creating .env.production file..."
    cat > .env.production << 'EOF'
# Database Configuration
# Use SQLite (no PostgreSQL needed)
DB_TYPE=sqlite
DB_SQLITE_POOL_SIZE=0
DB_SQLITE_DATABASE=n8n.sqlite

# Disable features that need jsonb
N8N_DIAGNOSTICS_ENABLED=false
N8N_INSIGHTS_ENABLED=false

# Server Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=https

# Change this to your actual domain
WEBHOOK_URL=https://your-domain.hackclub.app

# Timezone
GENERIC_TIMEZONE=America/New_York
EOF
    echo "⚠️  Please edit .env.production and set your WEBHOOK_URL"
fi

echo "✅ Build complete!"
echo ""
echo "To start n8n, run:"
echo "  source .env.production && pnpm start"
echo ""
echo "Or to run in background with nohup:"
echo "  source .env.production && nohup pnpm start > n8n.log 2>&1 &"
echo ""
echo "To check if it's running:"
echo "  ps aux | grep n8n"
echo ""
echo "To view logs:"
echo "  tail -f n8n.log"
