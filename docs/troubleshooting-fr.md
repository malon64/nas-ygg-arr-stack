# Troubleshooting

Docs liées : [Paths](paths-fr.md) · [Setup](../SETUP-fr.md) · [Architecture](architecture.md)

- Le Raspberry Pi ne voit pas `/arr-data` :
  - vérifiez que l'export NFS est actif sur le NAS
  - confirmez que l'IP du Pi est autorisée
  - vérifiez que le montage existe bien et qu'il est inscriptible
- Radarr ou Sonarr ne voient pas les téléchargements qBittorrent :
  - confirmez que qBittorrent écrit dans `/arr-data/torrents/...`
  - confirmez que Radarr et Sonarr montent aussi `/arr-data`
  - confirmez que le client de téléchargement pointe vers l'IP/hostname du NAS, pas vers `vpn` une fois les apps déplacées sur le Pi
- Les imports font une copie au lieu d'un hardlink :
  - vérifiez que téléchargements et bibliothèque sont tous les deux sous `/arr-data`
  - vérifiez que les hardlinks sont activés dans Radarr et Sonarr
  - vérifiez que `/arr-data` sur le Pi est bien le montage NFS du NAS, pas un dossier local
- Sonarr ou Radarr affichent "directory does not exist" :
  - corrigez le path interne pour qu'il corresponde à `/arr-data/...`
  - ajoutez un Remote Path Mapping seulement si qBittorrent remonte un chemin différent
- Le healthcheck Gluetun échoue sur Synology :
  - ICMP est souvent bloqué sur DSM
  - fiez-vous aux logs et aux tests de connexion si la probe intégrée est trop bruyante
  - vérifiez les identifiants VPN et le chemin du profil OpenVPN custom
- L'accès distant Plex reste indisponible :
  - Plex tourne maintenant sur le Pi
  - redirigez TCP `32400` vers le Pi, pas vers le NAS
  - autorisez ce port sur le routeur et dans le firewall local
- La synchronisation Prowlarr échoue après migration :
  - supprimez les anciens indexers Jackett, FlareSolverr ou Ygege
  - reconfigurez des indexers natifs puis relancez la sync vers Radarr et Sonarr
