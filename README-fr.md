# Torrent stack pour NAS Synology

Stack Docker Compose pour NAS Synology :
- Tunnel Gluetun (NordVPN) pour qBittorrent
- Indexeurs YggTorrent : YgéGé (recommandé) et Jackett+FlareSolverr en complément
- Automatisation Radarr/Sonarr orchestrée par Prowlarr
- Ajout automatique depuis les watchlists Plex via Watchlistarr
- Lecture avec Plex

Contexte : l’accès YGG via Jackett+FlareSolverr provoquait des timeouts fréquents. YgéGé apporte une API plus rapide/stable. L’image YgéGé compressée avec UPX crashait sur un NAS Atom ancien -> un build sans UPX a été demandé. La stack est dimensionnée pour éviter les copies (hardlinks) et protéger le trafic torrent derrière un VPN.

Docs : [Architecture](docs/architecture.md) · [Paths](docs/paths-fr.md) · [Setup](SETUP-fr.md) · [Troubleshooting](docs/troubleshooting-fr.md)

Démarrage :
```
docker-compose up -d
```
