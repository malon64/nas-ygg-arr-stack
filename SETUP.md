# Setup Guide

Related docs: [Paths](docs/paths.md) · [Troubleshooting](docs/troubleshooting.md) · [Architecture](docs/architecture.md)

## 1) Topology
- Synology NAS runs `vpn` and `qbittorrent`
- Raspberry Pi runs `prowlarr`, `radarr`, `sonarr`, `watchlistarr`, and `plex`
- NAS exports `/volume1/arr-data` over NFS
- Raspberry Pi mounts that export at `/arr-data`

This layout keeps torrenting on the NAS, keeps media automation on the Pi, and preserves hardlink-friendly imports because every app still works against the same `/arr-data` tree.

## 2) Create the service user and folders
- Create a service user in DSM, note its UID and GID, and set those values in `.env` as `PUID` and `PGID`.
- Create the storage tree on the NAS:
  - `/volume1/arr-data/torrents/incomplete`
  - `/volume1/arr-data/torrents/completed`
  - `/volume1/arr-data/media/movies`
  - `/volume1/arr-data/media/shows`
- Create NAS-side config folders:
  - `/volume1/docker/vpn`
  - `/volume1/docker/qbittorrent`
- Create Raspberry Pi config folders on the Pi host, for example:
  - `/srv/docker/prowlarr`
  - `/srv/docker/radarr`
  - `/srv/docker/sonarr`
  - `/srv/docker/watchlistarr`
  - `/srv/docker/plex`
- Apply ownership on both hosts with your actual service UID/GID:
```bash
sudo chown -R <PUID>:<PGID> /volume1/arr-data /volume1/docker
sudo chown -R <PUID>:<PGID> /srv/docker
```

## 3) Prepare NFS between NAS and Pi
- Export `/volume1/arr-data` from the NAS NFS service.
- Authorize the Raspberry Pi IP to mount that export.
- Mount the export on the Pi at `/arr-data`.
- Verify the Pi can read and write:
```bash
touch /arr-data/.nfs-write-test && rm /arr-data/.nfs-write-test
```

Do not use different path roots on the Pi. `/arr-data` must remain the canonical path for Radarr, Sonarr, and Plex.

## 4) Copy example configs
- On the NAS:
```bash
cp .env.example .env
```
- On the Pi:
```bash
cp watchlistarr/config.example.yaml watchlistarr/config.yaml
```

Fill the files:
- `.env` on the NAS: VPN credentials, qBittorrent port, and NAS-side paths
- `.env` on the Pi: Pi-side `DOCKERCONFDIR`, `ARR_DATA_DIR=/arr-data`, Plex token values, and service ports
- `watchlistarr/config.yaml`: Sonarr/Radarr endpoints, root folders, and Plex token

## 5) First deploy sequence
You need shell access on each machine. SSH into the NAS and the Pi separately; DSM Container Manager alone is not enough for this split deployment.

- Start the NAS stack:
```bash
docker-compose -f nas/docker-compose.yml up -d
```
- Start the Pi stack:
```bash
docker-compose -f raspberrypi/docker-compose.yml up -d
```

Plex runs on the Pi in host mode. Remote access must forward TCP `32400` to the Raspberry Pi, not the NAS.

## 6) Configure qBittorrent on the NAS
- Open qBittorrent on the NAS LAN IP:
  - `http://<NAS-LAN-IP>:8080`
- Set:
  - incomplete downloads: `/arr-data/torrents/incomplete`
  - completed downloads: `/arr-data/torrents/completed`
- If you are migrating existing torrents, use `Set Location` so all active torrents now point inside `/arr-data/torrents/...`.

## 7) Configure Radarr and Sonarr on the Pi
- Access them on the Pi LAN IP:
  - Radarr: `http://<PI-LAN-IP>:7878`
  - Sonarr: `http://<PI-LAN-IP>:8989`
- Set root folders:
  - Radarr: `/arr-data/media/movies`
  - Sonarr: `/arr-data/media/shows`
- Enable hardlinks in both apps.
- Add qBittorrent as the download client:
  - host: `<NAS-LAN-IP>` or NAS hostname
  - port: `8080`
  - category paths under `/arr-data/torrents/...`
- If qBittorrent reports a different path than `/arr-data/...`, add a Remote Path Mapping as a fallback. Do not start with Remote Path Mapping unless the direct path test fails.

## 8) Configure Prowlarr on the Pi
- Access: `http://<PI-LAN-IP>:9696`
- Remove any old Jackett, FlareSolverr, Ygege, or custom YGG entries.
- Add only native indexers or direct Torznab-compatible indexers.
- Connect Prowlarr to:
  - Radarr: `http://radarr:7878`
  - Sonarr: `http://sonarr:8989`
- Re-sync the indexers after the Pi cutover.

## 9) Configure Plex on the Pi
- Access: `http://<PI-LAN-IP>:32400/web`
- If you are starting fresh, first deploy Plex once and claim the server:
  - Claim token docs: https://www.plex.tv/claim/
- If you migrate an existing Plex config, copy that config to the Pi-side Plex config folder before starting the container.
- Point Plex libraries to:
  - `/data/movies`
  - `/data/shows`
- Those container paths must map to `/arr-data/media/movies` and `/arr-data/media/shows` on the Pi host.
- After Plex is claimed and reachable, retrieve the Plex token for Watchlistarr:
  - Plex token docs: https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
- Forward TCP `32400` from the router to the Pi.

## 10) Configure Watchlistarr on the Pi
- Keep Watchlistarr on the Pi compose network with:
  - `http://radarr:7878`
  - `http://sonarr:8989`
- Use the Plex token obtained after the Plex setup.
- Keep Watchlistarr root folders aligned with the same `/arr-data/...` tree used by Radarr and Sonarr.

## 11) App access
- On the LAN:
  - qBittorrent: `http://<NAS-LAN-IP>:8080`
  - Prowlarr: `http://<PI-LAN-IP>:9696`
  - Radarr: `http://<PI-LAN-IP>:7878`
  - Sonarr: `http://<PI-LAN-IP>:8989`
  - Plex: `http://<PI-LAN-IP>:32400/web`
- From outside your network:
  - open only the ports you actually need
  - Plex usually needs TCP `32400`
  - keep the Arr apps closed to WAN unless you have a strong reason to expose them

## 12) Boot tasks
- On the NAS, add a DSM scheduled task triggered at boot:
```bash
cd /volume1/your-repo && docker-compose -f nas/docker-compose.yml up -d
```
- On the Pi, add a boot task or systemd service:
```bash
cd /path/to/your-repo && docker-compose -f raspberrypi/docker-compose.yml up -d
```

## 13) Sanity checks
- NFS:
  - the Pi can create and delete a file in `/arr-data`
- qBittorrent:
  - saves to `/arr-data/torrents/incomplete` and `/arr-data/torrents/completed`
  - reachable from Radarr and Sonarr using the NAS IP/hostname
- Radarr/Sonarr:
  - test connection to qBittorrent succeeds
  - imports land in `/arr-data/media/...`
  - imports use hardlinks, not copies
- Prowlarr:
  - indexer sync to Radarr and Sonarr succeeds after removing the old Jackett/Ygege entries
- Watchlistarr:
  - adding a title to the Plex watchlist triggers Radarr or Sonarr
- Plex:
  - local playback works on the Pi-hosted instance
  - Remote Access is green after moving port forwarding to the Pi
