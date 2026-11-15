# Routing

Infra tidak punya API sendiri. Kontrak API ada di [backend/docs/03-api](https://gitlab.com/databiota-fredd/backend/-/blob/development/docs/03-api/api-conventions.md).

Aturan routing reverse proxy (Caddy). Versi lokal sudah ada di [`caddy/Caddyfile`](../../caddy/Caddyfile) dan dipakai mode Docker:

| Path | Tujuan | Catatan |
|---|---|---|
| `/api/v1/events` | `api:8000` | SSE: `flush_interval -1`, tanpa timeout baca pendek |
| `/api/*` | `api:8000` | |
| `/webhooks/*` | `api:8000` | WhatsApp, Telegram, dan penyedia pembayaran (`/webhooks/payments/{provider}`). Body mentah diteruskan apa adanya untuk verifikasi tanda tangan |
| `/*` | `web:3000` | |

Header yang diteruskan: `X-Forwarded-For`, `X-Forwarded-Proto`, `Host`. FastAPI dijalankan dengan `--proxy-headers --forwarded-allow-ips` hanya untuk alamat Caddy.
