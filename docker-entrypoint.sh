#!/bin/sh
set -e

# Run the import command if nodes-info directory has files
if [ -d "/nodes-info" ] && [ "$(ls -A /nodes-info)" ]; then
  echo "Importing credentials from /nodes-info..."
  n8n import:credentials --separate --input=/nodes-info || echo "Import failed or already completed"
fi

# Start n8n normally
exec n8n "$@"
