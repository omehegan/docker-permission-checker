#!/bin/bash

echo "=== Docker Build Permission Check ==="
echo

# Basic user information
echo "User Information:"
echo "  UID: $(id -u)"
echo "  GID: $(id -g)"
echo "  User: $(whoami)"
echo "  Groups: $(groups)"
echo

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Permission Status: RUNNING AS ROOT"
else
    echo "Permission Status: Running as non-root user (UID: $(id -u))"
fi
echo

# Check Docker socket permissions (if mounted)
echo "Docker Socket Check:"
if [ -S /var/run/docker.sock ]; then
    echo "  Docker socket found: /var/run/docker.sock"
    echo "  Socket permissions: $(ls -la /var/run/docker.sock)"
    echo "  Socket ownership: $(stat -c '%U:%G' /var/run/docker.sock 2>/dev/null || stat -f '%Su:%Sg' /var/run/docker.sock 2>/dev/null)"
    
    # Test if we can access the socket
    if [ -r /var/run/docker.sock ] && [ -w /var/run/docker.sock ]; then
        echo "  Socket access: READ/WRITE available"
    elif [ -r /var/run/docker.sock ]; then
        echo "  Socket access: READ ONLY"
    else
        echo "  Socket access: NO ACCESS"
    fi
else
    echo "  Docker socket not found at /var/run/docker.sock"
fi
echo

# Check for Docker context indicators
echo "Docker Context Indicators:"

# Check for rootless indicators
if [ -n "$DOCKER_HOST" ]; then
    echo "  DOCKER_HOST set to: $DOCKER_HOST"
fi

if [ -n "$XDG_RUNTIME_DIR" ]; then
    echo "  XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
    if [ -S "$XDG_RUNTIME_DIR/docker.sock" ]; then
        echo "  Rootless docker socket found: $XDG_RUNTIME_DIR/docker.sock"
    fi
fi

# Check common rootless docker paths
for socket_path in \
    "$HOME/.docker/run/docker.sock" \
    "/run/user/$(id -u)/docker.sock" \
    "$XDG_RUNTIME_DIR/docker.sock"; do
    
    if [ -S "$socket_path" ]; then
        echo "  Potential rootless socket: $socket_path"
    fi
done

# Check for Docker-in-Docker indicators
if [ -f /.dockerenv ]; then
    echo "  Running inside Docker container (/.dockerenv exists)"
fi

echo

# Process information
echo "Process Information:"
echo "  PID: $$"
echo "  PPID: $PPID"
echo "  Process tree:"
ps -ef | head -10 | while read line; do echo "    $line"; done

echo
echo "=== End Permission Check ==="

# Exit with status indicating root/non-root
if [ "$(id -u)" -eq 0 ]; then
    exit 0  # Root
else
    exit 1  # Non-root
fi
