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
## Add custom files to SVM installation
if [ -d "/build-config/user/mods/[SVM] Server Value Modifier/" ]; then
    if [ -d "/opt/server/user/mods/[SVM] Server Value Modifier/" ]; then
        echo "Copying SVM mod from build-config directory..."
        cp -r "/build-config/user/mods/[SVM] Server Value Modifier/"* "/opt/server/user/mods/[SVM] Server Value Modifier/" || echo "Warning: Could not copy from build-config directory, but continuing..."
    else
        echo "Target SVM directory does not exist, skipping copy operation. Restart the server after the mods have been installed"
    fi
else
    echo "No SVM build-config directory found, skipping that step."
fi

## Add custom files to Lotus installation
if [ -d "/build-config/user/mods/Lunnayaluna Lotus" ]; then
    if [ -d "/opt/server/user/mods/Lunnayaluna Lotus" ]; then
        echo "Copying Lotus mod from build-config directory..."
        cp -r "/build-config/user/mods/Lunnayaluna Lotus/"* "/opt/server/user/mods/Lunnayaluna Lotus/" || echo "Warning: Could not copy from build-config directory, but continuing..."
    else
        echo "Target Lotus directory does not exist, skipping copy operation. Restart the server after the mods have been installed"
    fi
else
    echo "No Lotus build-config directory found, skipping that step."
fi


# Fix Croupier mod to be Linux-compatible
echo "Checking for Croupier mod to fix require statements..."

if [ -d "/opt/server/user/mods/zcroupier/" ]; then
    echo "Croupier mod folder found, fixing require statements..."
    
    # Count fixed files for reporting
    FIXED_FILES=0
    
    # Find all .js files in the directory and fix the require paths
    while IFS= read -r file; do
        # Check if the file contains problematic require statements
        if grep -q 'require("C:/snapshot/project/' "$file"; then
            echo "Fixing file: $file"
            sed -i 's|require("C:/snapshot/project/|require("/snapshot/project/|g' "$file"
            FIXED_FILES=$((FIXED_FILES + 1))
        fi
    done < <(find /opt/server/user/mods/zcroupier/ -type f -name "*.js")
    
    echo "Croupier mod fix completed. Fixed $FIXED_FILES files."
else
    echo "No Croupier mod folder found, skipping path fixes."
fi



echo "SPT server setup completed. Starting server..."

# Execute the original entrypoint
exec /usr/bin/entrypoint "$@"
