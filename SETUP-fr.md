# Guide de Setup

Docs liées : [Paths](docs/paths-fr.md) · [Troubleshooting](docs/troubleshooting-fr.md) · [Architecture](docs/architecture.md)

## 1) Topologie
- le NAS Synology exécute `vpn` et `qbittorrent`
- le Raspberry Pi exécute `prowlarr`, `radarr`, `sonarr`, `watchlistarr` et `plex`
- le NAS exporte `/volume1/arr-data` en NFS
- le Raspberry Pi monte cet export sur `/arr-data`

Cette topologie garde le torrenting sur le NAS, déplace l'automatisation media sur le Pi, et conserve des imports par hardlink car tout le monde travaille sur le même arbre `/arr-data`.

## 2) Créer l'utilisateur de service et les dossiers
- Créez un utilisateur de service dans DSM, relevez son UID et son GID, puis renseignez `PUID` et `PGID` dans `.env`.
- Créez l'arborescence de stockage sur le NAS :
  - `/volume1/arr-data/torrents/incomplete`
  - `/volume1/arr-data/torrents/completed`
  - `/volume1/arr-data/media/movies`
  - `/volume1/arr-data/media/shows`
- Créez les dossiers de config côté NAS :
  - `/volume1/docker/vpn`
  - `/volume1/docker/qbittorrent`
- Créez les dossiers de config côté Raspberry Pi, par exemple :
  - `/srv/docker/prowlarr`
  - `/srv/docker/radarr`
  - `/srv/docker/sonarr`
  - `/srv/docker/watchlistarr`
  - `/srv/docker/plex`
- Appliquez les droits avec votre UID/GID de service réel :
```bash
sudo chown -R <PUID>:<PGID> /volume1/arr-data /volume1/docker
sudo chown -R <PUID>:<PGID> /srv/docker
```

## 3) Préparer le NFS entre le NAS et le Pi
- Exportez `/volume1/arr-data` depuis le service NFS du NAS.
- Autorisez l'IP du Raspberry Pi à monter cet export.
- Montez l'export sur le Pi dans `/arr-data`.
- Vérifiez que le Pi peut lire et écrire :
```bash
touch /arr-data/.nfs-write-test && rm /arr-data/.nfs-write-test
```

N'utilisez pas un autre chemin racine sur le Pi. `/arr-data` doit rester le chemin canonique pour Radarr, Sonarr et Plex.

## 4) Copier les exemples
- Sur le NAS :
```bash
cp .env.example .env
```
- Sur le Pi :
```bash
cp watchlistarr/config.example.yaml watchlistarr/config.yaml
```

Renseignez les fichiers :
- `.env` sur le NAS : identifiants VPN, port qBittorrent, chemins côté NAS
- `.env` sur le Pi : `DOCKERCONFDIR` côté Pi, `ARR_DATA_DIR=/arr-data`, variables Plex, ports des services
- `watchlistarr/config.yaml` : endpoints Sonarr/Radarr, root folders et token Plex

## 5) Première séquence de déploiement
Vous avez besoin d'un shell sur chaque machine. Connectez-vous en SSH au NAS puis au Pi ; DSM Container Manager seul n'est pas suffisant pour ce déploiement en deux nœuds.

- Démarrez la stack NAS :
```bash
docker-compose -f nas/docker-compose.yml up -d
```
- Démarrez la stack Pi :
```bash
docker-compose -f raspberrypi/docker-compose.yml up -d
```

Plex tourne sur le Pi en mode host. L'accès distant doit donc rediriger le port TCP `32400` vers le Raspberry Pi, pas vers le NAS.

## 6) Configurer qBittorrent sur le NAS
- Ouvrez qBittorrent sur l'IP LAN du NAS :
  - `http://<IP-LAN-NAS>:8080`
- Réglez :
  - téléchargements incomplets : `/arr-data/torrents/incomplete`
  - téléchargements terminés : `/arr-data/torrents/completed`
- En cas de migration de torrents existants, utilisez `Set Location` pour que chaque torrent actif pointe désormais dans `/arr-data/torrents/...`.

## 7) Configurer Radarr et Sonarr sur le Pi
- Accès :
  - Radarr : `http://<IP-LAN-PI>:7878`
  - Sonarr : `http://<IP-LAN-PI>:8989`
- Définissez les root folders :
  - Radarr : `/arr-data/media/movies`
  - Sonarr : `/arr-data/media/shows`
- Activez les hardlinks dans les deux applications.
- Ajoutez qBittorrent comme client de téléchargement :
  - host : `<IP-LAN-NAS>` ou hostname du NAS
  - port : `8080`
  - chemins de catégories sous `/arr-data/torrents/...`
- Si qBittorrent remonte un chemin différent de `/arr-data/...`, ajoutez un Remote Path Mapping en dernier recours. Ne commencez pas par ça.

## 8) Configurer Prowlarr sur le Pi
- Accès : `http://<IP-LAN-PI>:9696`
- Supprimez les anciennes entrées Jackett, FlareSolverr, Ygege ou YGG custom.
- Utilisez uniquement des indexers natifs ou des indexers Torznab directs.
- Connectez Prowlarr à :
  - Radarr : `http://radarr:7878`
  - Sonarr : `http://sonarr:8989`
- Relancez la synchronisation des indexers après le cutover sur le Pi.

## 9) Configurer Plex sur le Pi
- Accès : `http://<IP-LAN-PI>:32400/web`
- Si vous partez de zéro, déployez Plex une première fois puis faites le claim du serveur :
  - doc claim token : https://www.plex.tv/claim/
- Si vous migrez une config Plex existante, copiez-la dans le dossier de config Plex côté Pi avant de démarrer le conteneur.
- Pointez les bibliothèques Plex vers :
  - `/data/movies`
  - `/data/shows`
- Ces chemins conteneur doivent être mappés sur `/arr-data/media/movies` et `/arr-data/media/shows` côté Pi.
- Une fois Plex claimé et accessible, récupérez le token Plex pour Watchlistarr :
  - doc Plex token : https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/
- Redirigez le port TCP `32400` du routeur vers le Pi.

## 10) Configurer Watchlistarr sur le Pi
- Gardez Watchlistarr sur le réseau compose du Pi avec :
  - `http://radarr:7878`
  - `http://sonarr:8989`
- Utilisez le token Plex obtenu après le Setup de Plex.
- Gardez les root folders Watchlistarr alignés sur le même arbre `/arr-data/...` que Radarr et Sonarr.

## 11) Accès aux applications
- Sur le LAN :
  - qBittorrent : `http://<IP-LAN-NAS>:8080`
  - Prowlarr : `http://<IP-LAN-PI>:9696`
  - Radarr : `http://<IP-LAN-PI>:7878`
  - Sonarr : `http://<IP-LAN-PI>:8989`
  - Plex : `http://<IP-LAN-PI>:32400/web`
- Depuis l'extérieur :
  - n'ouvrez que les ports réellement nécessaires
  - Plex utilise généralement TCP `32400`
  - gardez les apps Arr fermées au WAN sauf besoin explicite

## 12) Tâches de démarrage
- Sur le NAS, ajoutez une tâche planifiée DSM au démarrage :
```bash
cd /volume1/your-repo && docker-compose -f nas/docker-compose.yml up -d
```
- Sur le Pi, ajoutez une tâche de boot ou un service systemd :
```bash
cd /path/to/your-repo && docker-compose -f raspberrypi/docker-compose.yml up -d
```

## 13) Sanity checks
- NFS :
  - le Pi peut créer puis supprimer un fichier dans `/arr-data`
- qBittorrent :
  - écrit bien dans `/arr-data/torrents/incomplete` et `/arr-data/torrents/completed`
  - est joignable depuis Radarr et Sonarr via l'IP/hostname du NAS
- Radarr/Sonarr :
  - le test de connexion qBittorrent passe
  - les imports atterrissent dans `/arr-data/media/...`
  - les imports utilisent des hardlinks, pas des copies
- Prowlarr :
  - la synchronisation vers Radarr et Sonarr fonctionne après suppression des anciennes entrées Jackett/Ygege
- Watchlistarr :
  - l'ajout d'un titre dans la watchlist Plex déclenche bien Radarr ou Sonarr
- Plex :
  - la lecture locale fonctionne sur l'instance hébergée par le Pi
  - Remote Access est vert après avoir déplacé la redirection de port vers le Pi
