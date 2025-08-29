#!/bin/bash

echo "=== Docker Permission Testing Script ==="
echo

# Build the Docker image
echo "Building Docker image for permission testing..."
docker build -h
docker build -f Dockerfile.permissions --load -t docker-permissions-test .

if [ $? -ne 0 ]; then
    echo "Failed to build Docker image"
    exit 1
fi

echo
echo "=== Testing Root Permissions ==="
docker run --rm docker-permissions-test

echo
echo "=== Testing Non-Root Permissions ==="
docker run --rm docker-permissions-test:latest sh -c "
    addgroup -g 1001 testuser 2>/dev/null || true
    adduser -D -u 1001 -G testuser testuser 2>/dev/null || true
    su testuser -c '/usr/local/bin/check_docker_permissions.sh'
"

echo
echo "=== Testing with Docker Socket Mounted ==="
if [ -S /var/run/docker.sock ]; then
    echo "Mounting Docker socket..."
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock docker-permissions-test
else
    echo "Docker socket not found, skipping socket test"
fi

echo
echo "=== Testing with Buildx Context ==="
docker buildx build -f Dockerfile.permissions --progress=plain -t docker-permissions-buildx . 2>&1 | grep -E "(User Information|Permission Status|Docker Context)"

echo
echo "=== Testing Complete ==="
