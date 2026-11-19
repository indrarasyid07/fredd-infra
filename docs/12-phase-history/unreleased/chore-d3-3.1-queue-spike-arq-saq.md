## Worker antrean dan Redis tahan restart

- Service `worker` (`taskiq worker app.worker:broker`) dan `scheduler` (cron, satu instance) di profil `app`.
- Redis memakai AOF (`appendonly yes`, `appendfsync everysec`) dengan volume `redis-data`.
