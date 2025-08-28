ARG BASE=oven/bun:slim

# region :: Stage - Builder
# -------------------------------=-------------------------
FROM ${BASE} AS builder
SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]
USER root
# Set environment variable for non-interactive apt operations
ENV DEBIAN_FRONTEND=noninteractive

# region > Build Platform, Target
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETPLATFORM
ARG TARGETOS
# endregion

# region > prebuildfs
# -------------------------------------
COPY --from=prebuildfs usr/local/sbin/exec-script /usr/local/sbin/exec-script
COPY --from=prebuildfs usr/local/sbin/install-packages /usr/local/sbin/install-packages
# endregion

# region > Common Packages
# ------------------------------------
WORKDIR /build
ARG COMMON_PACKAGES_SCRIPT=common-packages.sh
COPY --from=scripts ${COMMON_PACKAGES_SCRIPT} scripts/
RUN --mount=type=tmpfs,destination=/tmp \
    --mount=type=cache,sharing=private,target=/var/log \
    --mount=type=cache,sharing=locked,target=/var/lib/apt/lists \
    --mount=type=cache,sharing=locked,target=/var/cache/apt/archives\
    --mount=type=cache,sharing=locked,target=/downloads \
exec-script scripts/${COMMON_PACKAGES_SCRIPT}
# endregion

# region > bun install
WORKDIR /app
# Build argument to control UI building (default: false)
ARG BUILD_UI=false
# Copy package files first for better caching
ARG BUILD_SCRIPT=build.sh
COPY --from=scripts ${BUILD_SCRIPT} scripts/
COPY package.json bun.lock ./
RUN --mount=type=tmpfs,destination=/tmp \
    --mount=type=cache,sharing=locked,target=/downloads \
    bun install --frozen-lockfile
# endregion

# region > bun build
WORKDIR /app
COPY . .
RUN --mount=type=tmpfs,destination=/tmp \
    --mount=type=cache,sharing=locked,target=/downloads \
    if [ "$BUILD_UI" = "true" ]; then bun run build && bun run compile; else bun run build:no-ui && bun run compile; fi
# endregion

# -------------------------------=-------------------------
# endregion


# region :: Stage - Production
FROM ${BASE} AS production
WORKDIR /app

# Create non-root user
RUN groupadd --gid 1001 cipher && useradd --system --uid 1001 -g cipher cipher


# Create .cipher directory with proper permissions for database
RUN mkdir -p /app/.cipher/database && \
    chown -R cipher:cipher /app/.cipher

# Copy only essential production files - compiled executable and config  
COPY --from=builder --chown=cipher:cipher /app/dist/cipher ./cipher
COPY --from=builder --chown=cipher:cipher /app/memAgent ./memAgent

# Create a minimal .env file for Docker (environment variables will be passed via docker)
RUN echo "# Docker environment - variables passed via docker run" > .env

# Environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    CONFIG_FILE=/app/memAgent/cipher.yml

# Switch to non-root user
USER cipher

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); const req = http.request({host:'localhost',port:process.env.PORT||3000,path:'/health'}, (res) => process.exit(res.statusCode === 200 ? 0 : 1)); req.on('error', () => process.exit(1)); req.end();"

# Single port for deployment platform
EXPOSE $PORT

# API server mode: REST APIs on single port using compiled executable
CMD ["sh", "-c", "./cipher --mode api --port $PORT --host 0.0.0.0 --agent $CONFIG_FILE"]

# endregion