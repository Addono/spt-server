#!/bin/bash

# This script is intended to be used as a startup script for the SPT server Docker container.
# It will overwrite some default configuration files with custom ones to tweak the server settings.
# This cannot be done during the build process, as the server folder is assumed to be mounted completely.
# As such, we instead do this during the startup process.

# Enable error handling
set -e

echo "Starting SPT server setup script..."

# Ensure the target directory exists
echo "Ensuring target directories exist..."
mkdir -p /opt/server/user/mods/
mkdir -p "/opt/server/user/mods/[SVM] Server Value Modifier/"

# Check if the source remains directory exists
if [ -d "mod_downloads/remains/[SVM] Server Value Modifier/" ]; then
  echo "Moving SVM mod from remains directory..."
  mv "mod_downloads/remains/[SVM] Server Value Modifier/"* "/opt/server/user/mods/[SVM] Server Value Modifier/" || echo "Warning: Could not move from remains directory, but continuing..."
else
    echo "No SVM remains directory found, skipping that step."
fi

# Check if the build-config directory exists
if [ -d "/build-config/user/mods/[SVM] Server Value Modifier/" ]; then
    echo "Copying SVM mod from build-config directory..."
    cp -r "/build-config/user/mods/[SVM] Server Value Modifier/"* "/opt/server/user/mods/[SVM] Server Value Modifier/" || echo "Warning: Could not copy from build-config directory, but continuing..."
else
    echo "No SVM build-config directory found, skipping that step."
fi

echo "SPT server setup completed. Starting server..."

# Execute the original entrypoint
exec /usr/bin/entrypoint "$@"
