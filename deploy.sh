#!/bin/bash
set -e

echo "🚀 Deploying n8n to server..."

# Configuration
REMOTE_USER="${DEPLOY_USER:-root}"
REMOTE_HOST="${DEPLOY_HOST}"
REMOTE_DIR="${DEPLOY_DIR:-/opt/hc-n8n}"

if [ -z "$REMOTE_HOST" ]; then
    echo "❌ Error: DEPLOY_HOST environment variable is required"
    echo "Usage: DEPLOY_HOST=your-server.com ./deploy.sh"
    exit 1
fi

echo "📦 Building Docker image locally..."
docker build -f docker/images/n8n/Dockerfile -t hc-n8n:latest .

echo "💾 Saving Docker image to tar..."
docker save hc-n8n:latest | gzip > hc-n8n-image.tar.gz

echo "📤 Uploading to server..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}"
scp hc-n8n-image.tar.gz ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
scp docker-compose.deploy.yml ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/docker-compose.yml

echo "🔧 Setting up on server..."
ssh ${REMOTE_USER}@${REMOTE_HOST} << 'ENDSSH'
cd ${REMOTE_DIR:-/opt/hc-n8n}

# Load Docker image
echo "📥 Loading Docker image..."
docker load < hc-n8n-image.tar.gz

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Start services
echo "▶️  Starting services..."
docker-compose up -d

# Show status
echo "✅ Deployment complete!"
docker-compose ps

# Show logs
echo "📋 Recent logs:"
docker-compose logs --tail=50
ENDSSH

echo "🎉 Deployment finished!"
echo "Access n8n at: http://${REMOTE_HOST}:5678"

# Cleanup
rm hc-n8n-image.tar.gz
