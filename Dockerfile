# Build the main image
FROM ghcr.io/zhliau/fika-spt-server-docker:3.10.5

COPY mount /build-config/
