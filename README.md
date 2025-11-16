# nas-ygg-arr-stack — Torrent media stack for Synology

Docker Compose stack for Synology NAS that:
- Tunnels qBittorrent through Gluetun (NordVPN)
- Targets YggTorrent via YgéGé (preferred) and still ships Jackett+FlareSolverr
- Automates Radarr/Sonarr with Prowlarr
- Syncs Plex watchlists into Radarr/Sonarr with Watchlistarr
- Serves media with Plex

Context: Jackett+FlareSolverr against YGG caused frequent timeouts. YgéGé provides a faster, more stable API. The UPX-compressed YgéGé image crashed on an older Atom NAS, so a non-UPX build has been requested. The stack is wired for hardlinks (no duplicate copies) and keeps torrent traffic behind a VPN.

Docs: [Architecture](docs/architecture.md) · [Paths](docs/paths.md) · [Setup (EN)](SETUP.md) · [Troubleshooting](docs/troubleshooting.md) · [README français](README-fr.md)

Start:
```
docker-compose up -d
```
