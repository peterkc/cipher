#!/usr/bin/env bash
# Cipher Build Script for Docker Container
# Handles Bun dependency installation and build processes

set -euo pipefail

# Configuration
BUILD_UI="${BUILD_UI:-false}"
NODE_ENV="${NODE_ENV:-production}"
ENABLE_CACHE="${ENABLE_CACHE:-true}"

# Logging function
log() {
    echo "[$(date -Iseconds)] BUILD: $*" >&2
}

error_exit() {
    echo "[$(date -Iseconds)] ERROR: $*" >&2
    exit 1
}

# Validate environment
validate_environment() {
    log "Validating build environment..."
    
    # Check if we're in the right directory
    if [ ! -f "package.json" ]; then
        error_exit "package.json not found - are we in the correct directory?"
    fi
    
    # Check if bun is available
    if ! command -v bun >/dev/null 2>&1; then
        error_exit "Bun runtime not found"
    fi
    
    # Log build configuration
    log "Build Configuration:"
    log "  UI Build: $BUILD_UI"
    log "  Environment: $NODE_ENV"
    log "  Cache: $ENABLE_CACHE"
    
    # Check available disk space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 1000000 ]; then  # 1GB in KB
        log "WARNING: Low disk space: ${available_space}KB"
    fi
}

# Install dependencies
install_dependencies() {
    log "Installing dependencies with Bun..."
    
    local install_args="--frozen-lockfile"
    
    # Add cache options if enabled
    if [ "$ENABLE_CACHE" = "true" ]; then
        install_args="$install_args --verbose"
    fi
    
    # Production vs development dependencies
    if [ "$NODE_ENV" = "production" ]; then
        install_args="$install_args --production"
        log "Installing production dependencies only"
    else
        log "Installing all dependencies (including dev dependencies)"
    fi
    
    # Execute installation with timing
    local start_time=$(date +%s)
    
    if bun install $install_args; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log "Dependencies installed successfully in ${duration}s"
        
        # Log package count
        local package_count=$(find node_modules -name package.json | wc -l)
        log "Total packages installed: $package_count"
    else
        error_exit "Failed to install dependencies"
    fi
}

# Build application
build_application() {
    log "Building Cipher application..."
    
    # Determine build command based on UI flag
    local build_cmd
    if [ "$BUILD_UI" = "true" ]; then
        build_cmd="compile"
        log "Building with UI components"
    else
        build_cmd="compile:no-ui"
        log "Building without UI components (API only)"
    fi
    
    # Check if build script exists
    if ! bun run --silent $build_cmd --dry-run >/dev/null 2>&1; then
        log "Warning: Build script '$build_cmd' not found, trying fallback"
        if [ "$BUILD_UI" = "true" ]; then
            build_cmd="build"
        else
            build_cmd="build:backend"
        fi
    fi
    
    # Execute build
    local start_time=$(date +%s)
    
    if bun run $build_cmd; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        log "Application built successfully in ${duration}s"
        
        # Verify build output
        if [ -d "dist" ]; then
            local dist_size=$(du -sh dist | cut -f1)
            log "Build output size: $dist_size"
        else
            log "Warning: dist directory not found after build"
        fi
    else
        error_exit "Failed to build application"
    fi
}

# Cleanup function
cleanup_build() {
    log "Cleaning up build artifacts..."
    
    # Remove unnecessary files for production
    if [ "$NODE_ENV" = "production" ]; then
        # Clean up development dependencies if they exist
        if [ -d "node_modules" ]; then
            log "Cleaning development dependencies..."
            # Keep only production dependencies
            bun install --frozen-lockfile --production >/dev/null 2>&1 || true
        fi
        
        # Remove build caches
        rm -rf .turbo 2>/dev/null || true
        rm -rf .next 2>/dev/null || true
        rm -rf .cache 2>/dev/null || true
        
        log "Production cleanup completed"
    fi
}

# Health check
verify_build() {
    log "Verifying build output..."
    
    local errors=0
    
    # Check if main executable exists
    if [ -f "dist/cipher" ]; then
        log "✓ Main executable found: dist/cipher"
    elif [ -f "dist/index.js" ]; then
        log "✓ Main script found: dist/index.js"
    else
        log "✗ Main executable/script not found in dist/"
        errors=$((errors + 1))
    fi
    
    # Check if required configuration exists
    if [ -d "memAgent" ]; then
        log "✓ memAgent configuration found"
    else
        log "⚠ memAgent configuration not found"
    fi
    
    # Summary
    if [ $errors -eq 0 ]; then
        log "Build verification passed"
    else
        error_exit "Build verification failed with $errors errors"
    fi
}

# Main execution
main() {
    log "Starting Cipher build process..."
    
    validate_environment
    install_dependencies
    build_application
    cleanup_build
    verify_build
    
    log "Build process completed successfully!"
}

# Execute main function
main "$@"