# Conventions de Paths

Docs liées : [Setup](../SETUP-fr.md) · [Troubleshooting](troubleshooting-fr.md) · [Architecture](architecture.md)

## Modèle de stockage canonique
- le NAS exporte `/volume1/arr-data` en NFS
- le Raspberry Pi monte cet export dans `/arr-data`
- toutes les applications media doivent utiliser le même arbre logique afin que les imports utilisent des hardlinks au lieu de copies

## Paths attendus
- téléchargements qBittorrent :
  - `/arr-data/torrents/incomplete`
  - `/arr-data/torrents/completed`
- bibliothèque Radarr :
  - `/arr-data/media/movies`
- bibliothèque Sonarr :
  - `/arr-data/media/shows`
- bibliothèques Plex dans le conteneur :
  - `/data/movies`
  - `/data/shows`
- montages host Plex sur le Pi :
  - `/arr-data/media/movies`
  - `/arr-data/media/shows`
- Watchlistarr :
  - gardez les mêmes roots `/arr-data/media/...` si vous définissez des root folders

## Réglages courants
- qBittorrent tourne sur le NAS et ne doit écrire que dans `/arr-data/torrents/...`.
- Radarr et Sonarr tournent sur le Pi et ne doivent utiliser que `/arr-data/media/...` et `/arr-data/torrents/...`.
- Radarr et Sonarr se connectent à qBittorrent via l'IP LAN ou le hostname du NAS, port `8080`.
- Prowlarr tourne sur le Pi et doit utiliser uniquement des indexers natifs/directs. N'utilisez plus Jackett, FlareSolverr ou Ygege dans ce repo.
- Watchlistarr parle à :
  - `http://radarr:7878`
  - `http://sonarr:8989`

## Remote Path Mapping en dernier recours
Si qBittorrent remonte un chemin spécifique à l'hôte que Radarr ou Sonarr ne savent pas résoudre, ajoutez un Remote Path Mapping. C'est un fallback, pas le design cible. Le design cible est un seul path racine canonique : `/arr-data`.
