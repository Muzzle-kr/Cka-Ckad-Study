#!/bin/sh

# Health check script for Docker container
PORT=${PORT:-8080}
HEALTH_ENDPOINT="http://localhost:$PORT"

# Check if the application is responding
if curl -f -s $HEALTH_ENDPOINT > /dev/null; then
    echo "Health check passed: Application is responding on port $PORT"
    exit 0
else
    echo "Health check failed: Application not responding on port $PORT"
    exit 1
fi