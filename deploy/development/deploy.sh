#!/usr/bin/env bash
# Runs ON the development server, from /opt/fluctuz, called by the deploy workflows:
#   ./deploy.sh api      after a fredd-backend build (pulls the api image, migrates)
#   ./deploy.sh web      after a fredd-frontend build
#   ./deploy.sh          after a fredd-infra change (no pull, re-applies compose/Caddyfile)
# A GHCR login must already be in place when pulling; the workflow logs in and out around this.
set -euo pipefail
cd "$(dirname "$0")"

# Backend and frontend may finish at the same time: one deploy at a time.
exec 9>.deploy.lock
flock -w 600 9

test -f .env || { echo "missing /opt/fluctuz/.env (copy .env.example)" >&2; exit 1; }
compose=(docker compose -f docker-compose-dev.yml)

case "${1:-}" in
  api) "${compose[@]}" pull migrate api ;;
  web) "${compose[@]}" pull web ;;
  "") ;;
  *) echo "usage: $0 [api|web]" >&2; exit 2 ;;
esac

"${compose[@]}" up -d --wait postgres redis
# Named volumes start root-owned; the app runs as uid 1000.
"${compose[@]}" run --rm -T --no-deps --user root --entrypoint chown migrate -R 1000:1000 /app/var/media
"${compose[@]}" run --rm -T migrate
"${compose[@]}" up -d --wait --remove-orphans

# Keep the last few builds for rollback, drop the rest.
docker image prune -f --filter "until=168h" >/dev/null

port="$(grep -E '^APP_PORT=' .env | cut -d= -f2)"
curl -fsS --retry 10 --retry-delay 3 --retry-all-errors "http://127.0.0.1:${port:-8095}/api/v1/health"
echo
"${compose[@]}" ps --format 'table {{.Service}}\t{{.Image}}\t{{.Status}}'
