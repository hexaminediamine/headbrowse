#!/bin/bash
# Setup script for headless browser tool

echo "=== Setting up headless browser tool ==="

# Create directories if they don't exist
mkdir -p src/browser src/api src/ui/public

# Move files to their correct locations
echo "Moving files to correct locations..."

# Main application file
if [ -f index.js ]; then
  mv index.js src/
elif [ -f src/index.js ]; then
  echo "index.js already in correct location"
fi

# Browser controller
if [ -f controller.js ]; then
  mv controller.js src/browser/
elif [ -f src/browser/controller.js ]; then
  echo "controller.js already in correct location"
fi

# API routes
if [ -f routes.js ]; then
  mv routes.js src/api/
elif [ -f src/api/routes.js ]; then
  echo "routes.js already in correct location"
fi

# UI file
if [ -f index.html ]; then
  mv index.html src/ui/
elif [ -f src/ui/index.html ]; then
  echo "index.html already in correct location"
fi

# Check for package.json in root directory
if [ ! -f package.json ]; then
  echo "Creating package.json..."
  cat > package.json << 'EOL'
{
  "name": "headless-browser-tool",
  "version": "1.0.0",
  "description": "Deployable headless browser with simple UI",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "playwright": "^1.38.0",
    "socket.io": "^4.7.2"
  },
  "devDependencies": {
    "jest": "^29.6.4"
  }
}
EOL
fi

# Check for Dockerfile in root directory
if [ ! -f Dockerfile ]; then
  echo "Creating Dockerfile..."
  cat > Dockerfile << 'EOL'
FROM node:18-slim

# Install dependencies for Chromium
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    xdg-utils \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install
# Install Playwright
RUN npx playwright install chromium --with-deps

# Copy source code
COPY . .

# Expose port for web UI
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
EOL
fi

# Check for docker-compose.yml in root directory
if [ ! -f docker-compose.yml ]; then
  echo "Creating docker-compose.yml..."
  cat > docker-compose.yml << 'EOL'
version: '3'

services:
  headless-browser:
    build: .
    ports:
      - "3000:3000"
    restart: unless-stopped
    volumes:
      # For development: mount source code for quick changes
      # - ./src:/app/src
      # For data persistence if needed
      - browser-data:/app/data
    environment:
      - NODE_ENV=production
      - PORT=3000

volumes:
  browser-data:
EOL
fi

echo "Setup complete!"
echo "You can now build and run the container with:"
echo "docker-compose up -d"
echo ""
echo "Access the UI at http://[your-server-ip]:3000"

# Optionally build and run the container
read -p "Would you like to build and run the container now? (y/n) " answer
if [[ $answer == "y" || $answer == "Y" ]]; then
  echo "Building and starting container..."
  docker-compose up -d
  echo "Container is running!"
  echo "Access the UI at http://localhost:3000 or http://[your-server-ip]:3000"
fi
