# Guide de configuration (Synology)

## 1) Utilisateur et dossiers
- Créez un utilisateur de service (ex. `arr-user`) dans DSM et notez son UID/GID; mettez-les dans `.env` (`PUID/PGID`).
- Créez les dossiers :
  - `/volume1/arr-data` (sous-dossiers `torrents/incomplete`, `torrents/completed`, `media/movies`, `media/shows`)
  - `/volume1/docker` pour les configs, avec sous-dossiers : `vpn`, `qbittorrent`, `jackett`, `flaresolverr`, `prowlarr`, `radarr`, `sonarr`, `plex`, `watchlistarr`, `ygege`
- Droits : `sudo chown -R <PUID>:<PGID> /volume1/arr-data /volume1/docker` (adaptez à votre UID/GID).

## 2) Copier les exemples
```
cp .env.example .env
cp ygege/config.example.json ygege/config.json
cp watchlistarr/config.example.yaml watchlistarr/config.yaml
```
Remplissez `.env` (chemins, ports, VPN). Ajoutez vos identifiants YGG dans `ygege/config.json` et vos clés API + token Plex dans `watchlistarr/config.yaml`.

## 3) Déploiement
```
docker-compose up -d
```
Plex est en mode host; ouvrez le port TCP 32400 sur votre routeur pour l’accès distant.

## 4) Paramétrage des applis
- qBittorrent (derrière VPN) : chemins incomplets/complets sous `/arr-data/torrents/incomplete` et `/arr-data/torrents/completed`.
- Radarr/Sonarr : dossiers racine `/arr-data/media/movies` et `/arr-data/media/shows`; activez les hardlinks. Client de téléchargement : hôte `vpn`, port `8080`, chemins `/arr-data/torrents/...`.
- Jackett : accessible sur `http://jackett:9117` (réseau `media-net`).
- FlareSolverr : `http://flaresolverr:8191`.
- Prowlarr : ajoutez Jackett (`http://jackett:9117`) et YgéGé (`http://ygege:8715/` ou entrée `extra_hosts`); synchronisez vers Radarr/Sonarr.
- Watchlistarr : endpoints `http://radarr:7878`, `http://sonarr:8989`, token Plex; utilisez les chemins `/arr-data` dans sa config.
- Plex : bibliothèques pointant vers `/data/movies` et `/data/shows` (mappés sur `/volume1/arr-data/media/...`).
  - Déployez Plex une première fois pour le claim/config (si besoin) : https://www.plex.tv/claim/
  - Récupérez ensuite le token Plex pour Watchlistarr après le claim : https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
  - Accès distant : redirigez le port TCP 32400 sur votre routeur, autorisez-le dans le firewall DSM.

## 5) Remarques
- Gardez téléchargements et médiathèque dans `/arr-data` pour autoriser les hardlinks.
- YgéGé requiert un `config.json` valide; le cache de session est dans `/volume1/docker/ygege/sessions`.
- Supprimez `PLEX_CLAIM` après l’enregistrement initial si vous restaurez un appdata Plex existant.
- Pour démarrer la stack sur Synology, activez l’accès SSH/terminal et lancez `docker-compose up -d`. Une fois les conteneurs démarrés, accédez aux applis sur le LAN via `http://<IP-NAS>:<port>` (ex. 8080 qBittorrent, 9117 Jackett, 9696 Prowlarr, 7878 Radarr, 8989 Sonarr, 8191 FlareSolverr, Plex sur `http://<NAS>:32400/web`). Depuis l’extérieur, ouvrez/redirigez les ports nécessaires (au minimum Plex 32400; les autres seulement si vous les exposez en WAN).
- Ajoutez une tâche planifiée DSM “au démarrage” qui exécute `cd /volume1/your-repo && docker-compose up -d` pour relancer la stack automatiquement après reboot.
