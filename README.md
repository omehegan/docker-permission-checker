# Docker Permission Checker

A utility to assert and test Docker build permissions, including detection of rootless Docker configurations.

## Files

- **`check_docker_permissions.sh`** - Main script that checks user permissions, Docker socket access, and rootless indicators
- **`Dockerfile.permissions`** - Multi-stage Dockerfile for testing both root and non-root scenarios
- **`test_docker_permissions.sh`** - Test runner that executes various permission test scenarios

## Usage

### Quick Test
```bash
# Build and run basic permission check
docker build -f Dockerfile.permissions -t docker-permissions-test .
docker run --rm docker-permissions-test
```

### Comprehensive Testing
```bash
# Run all test scenarios
./test_docker_permissions.sh
```

### Manual Script Execution
```bash
# Run permission check directly
./check_docker_permissions.sh
```

## What It Checks

- User ID, GID, and group membership
- Root vs non-root execution status
- Docker socket permissions and accessibility
- Rootless Docker indicators (XDG_RUNTIME_DIR, alternative socket paths)
- Docker-in-Docker detection
- Process information and hierarchy

## Exit Codes

The `check_docker_permissions.sh` script returns:
- `0` if running as root
- `1` if running as non-root

## Examples

### Testing with Docker Socket
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock docker-permissions-test
```

### Testing Non-Root User
```bash
docker run --rm --user 1001:1001 docker-permissions-test
```

### Build-Time Permission Check
Uncomment the `RUN` line in `Dockerfile.permissions` to check permissions during build.
