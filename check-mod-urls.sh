#!/bin/bash

echo "Checking mod URLs from fly.toml..."

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is not installed. Please install it using:"
    echo "  brew install yq   # for macOS"
    echo "  apt-get install yq   # for Ubuntu/Debian"
    exit 1
fi

# Extract URLs using yq
URLS=$(yq -r '.env.MOD_URLS_TO_DOWNLOAD' fly.toml | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v "^$" | grep "^http")

# Count total number of URLs to check
TOTAL_URLS=$(echo "$URLS" | wc -l)
echo "Found $TOTAL_URLS URLs to check."

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_URLS=()

echo "Starting validation..."
echo

# Loop through each URL
while IFS= read -r url; do
  # Skip empty lines
  if [ -z "$url" ]; then
    continue
  fi

  # Clean up URL (remove trailing quotes or other characters)
  url=$(echo "$url" | tr -d "'\"\`")

  echo -n "Checking $url ... "
  
  # Custom handling for different URL types
  if [[ "$url" == *"github.com"* || "$url" == *"sp-tarkov.com"* ]]; then
    # GitHub and SP-Tarkov URLs
    HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" "$url")
  elif [[ "$url" == *"drive.usercontent.google.com"* ]]; then
    # Google Drive URLs
    HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" "$url")
  elif [[ "$url" == *"discord"* ]]; then
    # Discord URLs - some may expire
    HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" "$url")
  else
    # General case
    HTTP_CODE=$(curl -s -L -o /dev/null -w "%{http_code}" "$url")
  fi
  
  if [ "$HTTP_CODE" == "200" ]; then
    echo "OK (HTTP $HTTP_CODE)"
    ((SUCCESS_COUNT++))
  else
    echo "FAILED (HTTP $HTTP_CODE)"
    FAILED_URLS+=("$url (HTTP $HTTP_CODE)")
    ((FAILED_COUNT++))
  fi
done <<< "$URLS"

echo
echo "========== Summary ==========="
echo "Total URLs: $TOTAL_URLS"
echo "Successful: $SUCCESS_COUNT"
echo "Failed:     $FAILED_COUNT"

if [ ${#FAILED_URLS[@]} -gt 0 ]; then
  echo
  echo "Failed URLs:"
  for failed_url in "${FAILED_URLS[@]}"; do
    echo " - $failed_url"
  done
  echo
  echo "You might need to update these URLs in your fly.toml file."
  exit 1
else
  echo
  echo "All mod URLs are valid! 🎉"
  exit 0
fi
