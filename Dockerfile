# Build the main image
FROM ghcr.io/zhliau/fika-spt-server-docker:3.11.3

# Install additional tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    htop \
    vim \
    nano

COPY mount /build-config/

# Add the startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Set our startup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/startup.sh"]
