# Dépannage

- YgéGé exit code 139 : arch incompatible (Atom/UPX) ou config manquante. Vérifiez que `${DOCKERCONFDIR}/ygege/config.json` est un fichier avec vos identifiants YGG; demandez une build sans UPX pour les Atom anciens.
- YgéGé "Is a directory (os error 21)" : le chemin host `config.json` est un dossier. Remplacez-le par un vrai fichier et remontez le conteneur.
- Prowlarr ne voit pas ygege : URL `http://ygege:8715/`; si DNS en échec, ajoutez `extra_hosts` avec l'IP de ygege ou recréez le réseau compose.
- Sonarr/Radarr "directory does not exist" : montez `/arr-data` (et/ou `/downloads`) dans tous les conteneurs, gardez téléchargements et médiathèque dans `/arr-data`, activez les hardlinks.
- Gluetun healthcheck KO sur Synology : ICMP bloqué; fiez-vous aux logs ou augmentez `start_period`. Vérifiez les identifiants VPN.
- Accès distant Plex : redirigez TCP 32400 sur le routeur et autorisez-le dans le firewall DSM; Plex tourne en host mode.
