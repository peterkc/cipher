#!/usr/bin/env just --timestamp --highlight --working-directory . --justfile

# ---------------------------------------------------------

set shell := ["bash", "-cu"]
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

# ---------------------------------------------------------

set export
set positional-arguments
set dotenv-load
set ignore-comments
#set fallback

set allow-duplicate-recipes
set allow-duplicate-variables

# -----------------------------------------------------------------------------
SELF    := justfile()
WORKDIR := invocation_directory()

# -----------------------------------------------------------------------------
DOCKER_BUILDKIT := "1"
DOCKER_BUILDER  := env_var_or_default('DOCKER_BUILDER', 'orbstack')
DOCKER_CONTEXT  := env_var_or_default('DOCKER_CONTEXT', 'orbstack')
BUILDX_BAKE_ENTITLEMENTS_FS := "1"

# ---------------------------------------------------------

[doc('List available recipes')]
help:
    @just --list --explain

[private]
default: help

# ---------------------------------------------------------
env:
    env | sort

# -----------------------------------------------------------------------------
# buildx

alias bake := buildx-bake

[group('buildx')]
[doc('')]
buildx-bake target="default" +args="":
    docker context use ${DOCKER_CONTEXT}
    docker buildx --builder ${DOCKER_BUILDER} bake \
    --file "docker-bake.hcl" \
    {{target}} {{args}}