#!/bin/bash

# Check if the database exists
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null

if [ $? -eq 0 ]; then
  echo "Database already initialized. Applying updates..."
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/init.sql
else
  echo "Database not initialized. Running default entrypoint..."
  /usr/local/bin/docker-entrypoint.sh postgres
fi
