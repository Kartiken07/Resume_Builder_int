#!/bin/bash
set -e

# This script runs when PostgreSQL container starts for the first time
# It creates all required databases for ToolHub projects

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create database for Minima (URL Shortener)
    SELECT 'CREATE DATABASE url_db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'url_db')\gexec

    -- Create database for FileSharing System
    SELECT 'CREATE DATABASE filesharingsystem'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'filesharingsystem')\gexec

    -- Grant all privileges to user
    GRANT ALL PRIVILEGES ON DATABASE url_db TO "$POSTGRES_USER";
    GRANT ALL PRIVILEGES ON DATABASE filesharingsystem TO "$POSTGRES_USER";
EOSQL

echo "✓ All databases initialized successfully"
