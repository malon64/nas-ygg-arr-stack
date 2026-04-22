# Path conventions

Related docs: [Setup](../SETUP.md) · [Troubleshooting](troubleshooting.md) · [Architecture](architecture.md)

## Canonical storage model
- NAS exports `/volume1/arr-data` over NFS
- Raspberry Pi mounts that export at `/arr-data`
- Every media app must use the same logical storage tree so imports can hardlink instead of copy

## Expected paths
- qBittorrent downloads:
  - `/arr-data/torrents/incomplete`
  - `/arr-data/torrents/completed`
- Radarr library:
  - `/arr-data/media/movies`
- Sonarr library:
  - `/arr-data/media/shows`
- Plex libraries inside the container:
  - `/data/movies`
  - `/data/shows`
- Plex host-side mounts on the Pi:
  - `/arr-data/media/movies`
  - `/arr-data/media/shows`
- Watchlistarr:
  - keep the same `/arr-data/media/...` roots when defining root folders

## Common settings
- qBittorrent runs on the NAS and should only write inside `/arr-data/torrents/...`.
- Radarr and Sonarr run on the Pi and should only use `/arr-data/media/...` plus `/arr-data/torrents/...`.
- Radarr and Sonarr connect to qBittorrent using the NAS LAN IP or NAS hostname, port `8080`.
- Prowlarr runs on the Pi and should use direct/native indexers only. Do not rely on Jackett, FlareSolverr, or Ygege in this repo.
- Watchlistarr talks to:
  - `http://radarr:7878`
  - `http://sonarr:8989`

## Remote Path Mapping fallback
If qBittorrent reports a host-specific path that Radarr or Sonarr cannot resolve, add a Remote Path Mapping. That is a fallback, not the target design. The target design is one canonical path root: `/arr-data`.
