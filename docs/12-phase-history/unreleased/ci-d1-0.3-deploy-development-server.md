## Deploy otomatis server development

- `deploy/development/` (`docker-compose-dev.yml`, `deploy.sh`, `.env.example`): stack `fluctuz-dev` di VPS development, image dari GHCR, Caddy di port 8095.
- Workflow `deploy-development` menyalin compose, `deploy.sh`, dan Caddyfile ke `/opt/fluctuz` saat file itu berubah di `development`; hanya repo ini yang menyalin file ke server.
- api, worker, dan scheduler membaca `.env` server (`env_file`), jadi env var baru backend tidak perlu mengubah compose.
