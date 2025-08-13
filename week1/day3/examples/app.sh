#!/bin/sh

# Simple HTTP server for Docker practice
PORT=${PORT:-8080}
MESSAGE=${MESSAGE:-"Hello from Docker container!"}
APP_ENV=${APP_ENV:-"development"}

echo "Starting web server on port $PORT"
echo "Environment: $APP_ENV"
echo "Message: $MESSAGE"

# Create HTML content
cat > /tmp/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Docker Practice App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; margin: 0 auto; }
        .env { background: #f0f0f0; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Docker Practice Application</h1>
        <p><strong>Message:</strong> $MESSAGE</p>
        <div class="env">
            <h3>Environment Information:</h3>
            <p><strong>Environment:</strong> $APP_ENV</p>
            <p><strong>Port:</strong> $PORT</p>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Time:</strong> $(date)</p>
        </div>
        <h3>Container Info:</h3>
        <ul>
            <li>OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)</li>
            <li>User: $(whoami)</li>
            <li>Working Directory: $(pwd)</li>
        </ul>
    </div>
</body>
</html>
EOF

# Simple HTTP server using netcat
while true; do
    echo -e "HTTP/1.1 200 OK\nContent-Type: text/html\nContent-Length: $(wc -c < /tmp/index.html)\n\n$(cat /tmp/index.html)" | nc -l -p $PORT
done