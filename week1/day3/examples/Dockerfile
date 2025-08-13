FROM alpine:3.18

LABEL maintainer="cka-student" \
      description="Sample web application for CKA/CKAD practice"

# Install required packages
RUN apk add --no-cache \
    curl \
    netcat-openbsd \
    busybox-extras

# Create app directory
WORKDIR /app

# Copy application files
COPY app.sh /app/
COPY health-check.sh /app/

# Make scripts executable
RUN chmod +x /app/*.sh

# Create non-root user
RUN adduser -D -s /bin/sh appuser
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD /app/health-check.sh

# Start the application
CMD ["./app.sh"]