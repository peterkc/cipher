#!/usr/bin/env bash
# Enhanced Docker Buildx Configuration for Cipher
# Simplified approach with cloud builder support

set -euo pipefail

DOCKER_BUILDER=${DOCKER_BUILDER:-"cipher-builder"}
DOCKER_CLOUD_ENDPOINT=${DOCKER_CLOUD_ENDPOINT:-""}
PLATFORMS=${PLATFORMS:-"linux/amd64,linux/arm64,linux/arm/v7"}

# Logging function
log() {
    echo "[$(date -Iseconds)] BUILDX: $*" >&2
}

# Check if builder exists
check_builder() {
    if docker buildx inspect "${DOCKER_BUILDER}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Create builder based on configuration
create_builder() {
    if [ -n "$DOCKER_CLOUD_ENDPOINT" ] && [ "$DOCKER_CLOUD_ENDPOINT" != "default" ]; then
        log "Creating cloud builder: $DOCKER_BUILDER with endpoint: $DOCKER_CLOUD_ENDPOINT"
        docker buildx create --driver cloud --name "${DOCKER_BUILDER}" "${DOCKER_CLOUD_ENDPOINT}"
    else
        log "Creating container builder: $DOCKER_BUILDER"
        docker buildx create \
            --name "${DOCKER_BUILDER}" \
            --driver docker-container \
            --platform "${PLATFORMS}" \
            --use
    fi
}

# Main logic
main() {
    log "Configuring Docker buildx..."
    
    if check_builder; then
        log "Builder '${DOCKER_BUILDER}' already exists"
        
        # Use existing builder
        docker buildx use "${DOCKER_BUILDER}"
        log "Switched to builder: ${DOCKER_BUILDER}"
    else
        log "Builder '${DOCKER_BUILDER}' does not exist, creating..."
        create_builder
        
        # Use the newly created builder
        docker buildx use "${DOCKER_BUILDER}"
        log "Created and switched to builder: ${DOCKER_BUILDER}"
    fi
    
    # Show builder info
    log "Builder information:"
    docker buildx inspect "${DOCKER_BUILDER}" | grep -E "(Name|Endpoint|Platforms):" || true
    
    log "Buildx configuration completed"
}

# Execute main function
main "$@"