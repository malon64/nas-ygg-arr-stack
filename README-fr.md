# nas-ygg-arr-stack — stack media pour Synology

Stack media en deux nœuds pour un NAS Synology et un Raspberry Pi :
- le NAS garde `gluetun` + `qbittorrent`
- le Raspberry Pi exécute `prowlarr`, `radarr`, `sonarr`, `watchlistarr` et `plex`
- le NAS reste la source unique des données sous `/volume1/arr-data`
- le Raspberry Pi monte ce stockage en NFS sur `/arr-data`

Le repo ciblait auparavant YGG via Jackett, FlareSolverr puis Ygege. Cette voie n'est plus supportée ici. La topologie actuelle est plus simple : le trafic torrent reste isolé sur le NAS derrière le VPN, les applications media tournent sur le Pi, et tous les services consomment le même arbre `/arr-data` afin que Radarr et Sonarr créent des hardlinks au lieu de recopier les fichiers.

Docs : [Paths](docs/paths-fr.md) · [Setup](SETUP-fr.md) · [Troubleshooting](docs/troubleshooting-fr.md) · [Architecture](docs/architecture.md)

Démarrage des deux stacks :
```bash
docker-compose -f nas/docker-compose.yml up -d
docker-compose -f raspberrypi/docker-compose.yml up -d
```
