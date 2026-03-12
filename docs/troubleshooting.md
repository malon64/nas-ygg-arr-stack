# Troubleshooting

Related docs: [Paths](paths.md) · [Setup](../SETUP.md) · [Architecture](architecture.md)

- Raspberry Pi cannot see `/arr-data`:
  - check that the NFS export is enabled on the NAS
  - confirm the Pi IP is authorized
  - verify the Pi mount exists and is writable
- Radarr or Sonarr cannot see qBittorrent downloads:
  - confirm qBittorrent writes into `/arr-data/torrents/...`
  - confirm Radarr and Sonarr also mount `/arr-data`
  - confirm the download client points to the NAS IP/hostname, not to `vpn` once the apps run on the Pi
- Imports copy instead of hardlink:
  - verify downloads and libraries are both under `/arr-data`
  - verify hardlinks are enabled in Radarr and Sonarr
  - verify `/arr-data` on the Pi is the mounted NAS filesystem, not a local directory
- Sonarr or Radarr reports "directory does not exist":
  - fix the in-container path so it matches `/arr-data/...`
  - add a Remote Path Mapping only if qBittorrent reports a different path
- Gluetun healthcheck fails on Synology:
  - ICMP is often blocked on DSM
  - rely on logs and connection tests if the built-in health probe is noisy
  - verify VPN credentials and custom OpenVPN profile paths
- Plex remote access stays unavailable:
  - Plex now runs on the Pi
  - forward TCP `32400` to the Pi, not the NAS
  - allow the port in the router and any local firewall
- Prowlarr sync fails after migration:
  - remove stale Jackett, FlareSolverr, or Ygege indexers
  - re-add native indexers and re-sync to Radarr and Sonarr
