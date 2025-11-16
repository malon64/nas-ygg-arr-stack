# Conventions de chemins

Chemins internes attendus (tous mappés sur `/volume1/arr-data` sur Synology) :

- Téléchargements (qBittorrent) : `/arr-data/torrents` (utilisez `/arr-data/torrents/incomplete` et `/arr-data/torrents/completed`)
- Médiathèque Radarr : `/arr-data/media/movies`
- Médiathèque Sonarr : `/arr-data/media/shows`
- Bibliothèques Plex : `/data/movies` et `/data/shows` (mappés sur `/arr-data/media/...`)

Gardez téléchargements et médiathèque sur le même filesystem (`/arr-data`) pour permettre les hardlinks.

## Réglages courants
- qBittorrent : chemins par défaut sous `/arr-data/torrents/...`; mettez à jour les torrents avec “Set Location” dans `/arr-data`.
- Radarr/Sonarr : dossiers racine `/arr-data/media/movies` et `/arr-data/media/shows`; activez les hardlinks; client de téléchargement hôte `vpn`, port `8080`, chemins `/arr-data/torrents/...`.
- Prowlarr : Jackett `http://jackett:9117`; YgéGé `http://ygege:8715/`.
- Watchlistarr : endpoints `http://radarr:7878`, `http://sonarr:8989`; token Plex requis.
