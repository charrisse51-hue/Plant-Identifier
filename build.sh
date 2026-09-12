#!/usr/bin/env bash
# Exit on error
set -o errexit

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --no-input

# Apply database migrations (run migrations if database is accessible)
python manage.py migrate --no-input || echo "[build.sh] Warning: Database migration did not finish during build. Ensure your DATABASE_URL uses the IPv4 Supabase Connection Pooler."

