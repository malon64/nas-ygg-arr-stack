# Setup Guide (Synology)

## 1) Users and folders
- Create a service user (e.g., `arr-user`) in DSM and note its UID/GID; set those in `.env` as `PUID/PGID`.
- Create folders:
  - `/volume1/arr-data` (with subfolders `torrents/incomplete`, `torrents/completed`, `media/movies`, `media/shows`)
  - `/volume1/docker` for configs, with subfolders: `vpn`, `qbittorrent`, `jackett`, `flaresolverr`, `prowlarr`, `radarr`, `sonarr`, `plex`, `watchlistarr`, `ygege`
- Ownership: set everything to your PUID/PGID, e.g. `sudo chown -R <PUID>:<PGID> /volume1/arr-data /volume1/docker`.

## 2) Copy example configs
```
cp .env.example .env
cp ygege/config.example.json ygege/config.json
cp watchlistarr/config.example.yaml watchlistarr/config.yaml
```
Fill `.env` (paths, ports, VPN creds). Add real YGG creds to `ygege/config.json`; add API keys and Plex token to `watchlistarr/config.yaml`.

## 3) Deploy
```
docker-compose up -d
```
Plex runs in host mode; forward TCP 32400 on your router for remote access.

## 4) App wiring
- qBittorrent (behind VPN): set incomplete/complete paths under `/arr-data/torrents/incomplete` and `/arr-data/torrents/completed`.
- Radarr/Sonarr: root folders `/arr-data/media/movies` and `/arr-data/media/shows`; enable hardlinks. Download client points to qBittorrent host `vpn`, port `8080`, category paths `/arr-data/torrents/...`.
- Jackett: reachable at `http://jackett:9117` on `media-net`.
- FlareSolverr: `http://flaresolverr:8191`.
- Prowlarr: add Jackett (`http://jackett:9117`) and YgéGé (use `http://ygege:8715/` or an `extra_hosts` entry); sync down to Radarr/Sonarr.
- Watchlistarr: endpoints `http://radarr:7878`, `http://sonarr:8989`, and Plex token; uses `/arr-data` paths in its config.
- Plex: libraries pointing to `/data/movies` and `/data/shows` (mapped to `/volume1/arr-data/media/...`).
  - First deploy Plex once to claim and configure the server (if needed): https://www.plex.tv/claim/
  - Then fetch a Plex token for Watchlistarr after Plex is claimed: https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
  - Remote access: forward TCP 32400 on your router, allow it in DSM firewall.

## 5) Notes
- Keep downloads and libraries under `/arr-data` to allow hardlinks.
- YgéGé requires a valid `config.json`; session cache persists in `/volume1/docker/ygege/sessions`.
- Remove `PLEX_CLAIM` after initial claim if you restore existing Plex appdata.
- To start the stack on Synology you need SSH/terminal access to run `docker-compose up -d`. Once running, access apps on LAN via `http://<NAS-LAN-IP>:<port>` (e.g. 8080 qBittorrent, 9117 Jackett, 9696 Prowlarr, 7878 Radarr, 8989 Sonarr, 8191 FlareSolverr, Plex at `http://<NAS>:32400/web`). From outside, open/forward the relevant ports (at least Plex 32400, and others only if you need WAN access).
- Add a DSM scheduled task to start the stack on boot, e.g. “Triggered at boot” running `cd /volume1/your-repo && docker-compose up -d`.
