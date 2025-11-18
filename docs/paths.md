# Path conventions

Internal container paths expected by the stack (all mapped to `/volume1/arr-data` on Synology):

- Downloads (qBittorrent): `/arr-data/torrents` (use `/arr-data/torrents/incomplete` and `/arr-data/torrents/completed`)
- Radarr library: `/arr-data/media/movies`
- Sonarr library: `/arr-data/media/shows`
- Plex libraries: `/data/movies` and `/data/shows` (mapped to the same `/arr-data/media/...` paths)
- Watchlistarr: use the same `/arr-data/media/...` paths if specifying root folders
- Recommendarr: persistent data at `/app/server/data`
- YgéGé: config at `/app/config.json`, sessions at `/app/sessions`

Keep downloads and libraries in the same filesystem (`/arr-data`) so Radarr/Sonarr can hardlink instead of copying.

## Common settings
- qBittorrent: default save paths to `/arr-data/torrents/...`; update existing torrents via “Set Location” to point inside `/arr-data`.
- Radarr/Sonarr: root folders `/arr-data/media/movies` and `/arr-data/media/shows`; enable hardlinks; download client host `vpn`, port `8080`, paths under `/arr-data/torrents/...`.
- Prowlarr: Jackett `http://jackett:9117`; YgéGé `http://ygege:8715/` (or `extra_hosts` if needed).
- Watchlistarr: endpoints `http://radarr:7878`, `http://sonarr:8989`; Plex token required.
