# region :: variables
variable "APP_VERSION" {
  default = "latest"
}

variable "REGISTRY" {
  default = "peterkc/cipher"
}

variable "BUN_VERSION" {
  default = "1.2.21"
}

variable "BUILD_UI" {
  default = "false"
}

variable "BUILDKIT_INLINE_CACHE" {
  default = "1"
}

variable "DOCKER_BUILDKIT" {
  default = "1"
}

# Build output control - cache-only by default, set PUSH_TO_REGISTRY=true to push
variable "PUSH_TO_REGISTRY" {
  default = "false"
}

variable "OUTPUT_TYPE" {
  default = "docker"
}
# endregion

# region :: groups
group "default" {
  targets = ["cipher-dev"]
}

group "development" {
  targets = ["cipher-dev"]
}

group "production" {
  targets = ["cipher-prod"]
}

group "release" {
  targets = ["cipher-release"]
}

group "all" {
  targets = ["cipher-dev", "cipher-prod", "cipher-release"]
}
# endregion

# region :: target - base
target "cipher-base" {
  contexts = {
    bun        = "docker-image://oven/bun:${BUN_VERSION}-slim"
    prebuildfs = "./docker/prebuildfs"
    scripts    = "./docker/scripts"
  }
  dockerfile = "docker-bake.dockerfile"
  args = {
    BUN_VERSION = "${BUN_VERSION}"
    BASE = "oven/bun:${BUN_VERSION}-slim"
  }
  # Base target for cache only
  output = ["type=docker"]
  pull = true
}
# endregion

# region :: target - dev
target "cipher-dev" {
  inherits = ["cipher-base"]
  args = {
    BUILD_UI = "${BUILD_UI}"
    NODE_ENV = "development"
  }
  tags = [
    "${REGISTRY}:dev-${APP_VERSION}",
    "${REGISTRY}:dev-latest"
  ]
  target = "production"

  # TODO
  # Cache export is not supported for the docker driver
  # See: https://docs.docker.com/go/build-cache-backends/

  # cache-from = [
  #   "type=gha,scope=cipher-dev",
  #   "type=registry,ref=${REGISTRY}:cache-dev"
  # ]
  # cache-to = [
  #   "type=gha,scope=cipher-dev,mode=max",
  #   "type=registry,ref=${REGISTRY}:cache-dev,mode=max"
  # ]
  labels = {
    "org.opencontainers.image.title" = "Cipher Development"
    "org.opencontainers.image.description" = "Cipher AI Agent Framework - Development Build"
    "org.opencontainers.image.version" = "${APP_VERSION}"
    "com.cipher.build.type" = "development"
    "com.cipher.bun.version" = "${BUN_VERSION}"
  }
  # Conditional output based on PUSH_TO_REGISTRY
  output = [PUSH_TO_REGISTRY == "true" ? "type=registry" : "type=${OUTPUT_TYPE}"]
}
# endregion

# region :: target - prod
target "cipher-prod" {
  inherits = ["cipher-base"]
  args = {
    BUILD_UI = "true"
    NODE_ENV = "production"
  }
  tags = [
    "${REGISTRY}:${APP_VERSION}",
    "${REGISTRY}:latest"
  ]
  target = "production"
  # cache-from = [
  #   "type=gha,scope=cipher-prod",
  #   "type=registry,ref=${REGISTRY}:cache-prod"
  # ]
  # cache-to = [
  #   "type=gha,scope=cipher-prod,mode=max",
  #   "type=registry,ref=${REGISTRY}:cache-prod,mode=max"
  # ]
  labels = {
    "org.opencontainers.image.title" = "Cipher Production"
    "org.opencontainers.image.description" = "Cipher AI Agent Framework - Production Build"
    "org.opencontainers.image.version" = "${APP_VERSION}"
    "com.cipher.build.type" = "production"
    "com.cipher.bun.version" = "${BUN_VERSION}"
  }
  # Conditional output based on PUSH_TO_REGISTRY
  output = [PUSH_TO_REGISTRY == "true" ? "type=registry" : "type=${OUTPUT_TYPE}"]
}
# endregion

# region :: target - release (multi-platform)
target "cipher-release" {
  inherits = ["cipher-prod"]
  platforms = ["linux/amd64", "linux/arm64", "linux/arm/v7"]
  args = {
    BUILD_UI = "true"
    NODE_ENV = "production"
  }
  tags = [
    "${REGISTRY}:${APP_VERSION}",
    "${REGISTRY}:latest",
    "${REGISTRY}:release-${APP_VERSION}"
  ]
  cache-from = [
    "type=gha,scope=cipher-release",
    "type=registry,ref=${REGISTRY}:cache-release"
  ]
  cache-to = [
    "type=gha,scope=cipher-release,mode=max",
    "type=registry,ref=${REGISTRY}:cache-release,mode=max"
  ]
  labels = {
    "org.opencontainers.image.title" = "Cipher Release"
    "org.opencontainers.image.description" = "Cipher AI Agent Framework - Multi-platform Release"
    "org.opencontainers.image.version" = "${APP_VERSION}"
    "com.cipher.build.type" = "release"
    "com.cipher.bun.version" = "${BUN_VERSION}"
    "com.cipher.platforms" = "linux/amd64,linux/arm64,linux/arm/v7"
  }
}
# endregion