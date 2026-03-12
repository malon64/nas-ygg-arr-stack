# nas-ygg-arr-stack — Torrent media stack for Synology

Two-node media stack for a Synology NAS and a Raspberry Pi:
- NAS keeps `gluetun` + `qbittorrent`
- Raspberry Pi runs `prowlarr`, `radarr`, `sonarr`, `watchlistarr`, and `plex`
- NAS storage stays the single source of truth under `/volume1/arr-data`
- Raspberry Pi mounts that storage over NFS at `/arr-data`

This repo used to target YGG through Jackett, FlareSolverr, and later Ygege. That path is no longer supported here. The current layout is simpler: keep torrent traffic isolated on the NAS behind the VPN, move the media apps to the Pi, and make every service read the same `/arr-data` tree so Radarr and Sonarr can hardlink instead of copying.

Docs: [Paths](docs/paths.md) · [Setup](SETUP.md) · [Troubleshooting](docs/troubleshooting.md) · [Architecture](docs/architecture.md) · [README French](README-fr.md)

Start the split stacks:
```bash
docker-compose -f nas/docker-compose.yml up -d
docker-compose -f raspberrypi/docker-compose.yml up -d
```
