# Build the main image
FROM ghcr.io/zhliau/fika-spt-server-docker:3.11.0

COPY mount /build-config/

# Add the startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Set our startup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/startup.sh"]
