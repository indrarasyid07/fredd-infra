## Bot Telegram di server development lewat polling (sementara)

- Service `telegram-poll` di `docker-compose-dev.yml` menjalankan `scripts.telegram_poll`, karena Telegram hanya memanggil webhook https dan server belum punya domain/TLS.
- Ikut image api, jadi ter-update setiap deploy backend. Hapus service ini dan pasang webhook begitu domain tersedia.
