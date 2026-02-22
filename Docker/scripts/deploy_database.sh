#!/bin/bash

source ./Docker/scripts/env_functions.sh

# Always load .env file if it exists, then let Docker env vars override
if [ -f .env ]; then
    export_env_vars
fi

# If DATABASE_PROVIDER is still empty, try to load from .env file explicitly
if [ -z "$DATABASE_PROVIDER" ]; then
    echo "Warning: DATABASE_PROVIDER not set via Docker env, trying .env file..."
    if [ -f .env ]; then
        export_env_vars
    fi
fi

echo "Starting with DATABASE_PROVIDER=$DATABASE_PROVIDER"

if [[ "$DATABASE_PROVIDER" == "postgresql" || "$DATABASE_PROVIDER" == "mysql" || "$DATABASE_PROVIDER" == "psql_bouncer" ]]; then
    export DATABASE_URL
    echo "Deploying migrations for $DATABASE_PROVIDER"
    echo "Database URL: $DATABASE_CONNECTION_URI"
    # rm -rf ./prisma/migrations
    # cp -r ./prisma/$DATABASE_PROVIDER-migrations ./prisma/migrations
    npm run db:deploy
    if [ $? -ne 0 ]; then
        echo "Migration failed"
        exit 1
    else
        echo "Migration succeeded"
    fi
    npm run db:generate
    if [ $? -ne 0 ]; then
        echo "Prisma generate failed"
        exit 1
    else
        echo "Prisma generate succeeded"
    fi
else
    echo "Error: Database provider $DATABASE_PROVIDER invalid."
    exit 1
fi
